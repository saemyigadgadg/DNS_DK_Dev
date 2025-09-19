/**
 * @description       : 
 * @author            : Daewook.KIM
 * @last modified on  : 05-22-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   11-06-2024   Daewook.KIM   Initial Version
**/

public without sharing class DN_PortalModalController {

    /**
     * @description 현재 User 정보
     */
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @description 현재 User 정보
     */
    public class WorkerInfoWrapper {
        @AuraEnabled public String      Id                      {get; set;} // ServiceResource ID
        @AuraEnabled public String      Name                    {get; set;} // ServiceResource Name
        @AuraEnabled public String      workerPartnerNumber     {get; set;} // ServiceResource SAP Partner Number
        @AuraEnabled public String      workCenterId            {get; set;} // WorkCenter ID
        @AuraEnabled public String      workCenterCode          {get; set;} // WorkCenter WC/ID
        @AuraEnabled public String      workCenterName          {get; set;} // WorkCenter Name
        @AuraEnabled public String      workCenterDivision      {get; set;} // WorkCenter Division
                
        public WorkerInfoWrapper() {}

        public WorkerInfoWrapper(
            String Id, String Name, String workerPartnerNumber, String workCenterId, String workCenterCode, String workCenterName, String workCenterDivision) {

            this.Id                     = Id;
            this.Name                   = Name;
            this.workerPartnerNumber    = workerPartnerNumber;
            this.workCenterId           = workCenterId;
            this.workCenterCode         = workCenterCode;
            this.workCenterName         = workCenterName;
            this.workCenterDivision     = workCenterDivision;
        }
    }

    /**
    * @description 로그인된 사용자 W/C에 속한 작업자 확인 (작업자 모달)
    **/
    @AuraEnabled
    public static Map<String, Object> getLoginUserInfo(String recordId, String type, Boolean isBranch) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<WorkerInfoWrapper> workerInfoList = new List<WorkerInfoWrapper>(); 
        List<Collaborator__c> collaboratorList = new List<Collaborator__c>(); 
        try {
            if (type == 'ServiceReport') {
                collaboratorList  = [SELECT Id, Name, ServiceResource__c, ServiceResource__r.Name, WorkOrder__c, ServiceResource__r.AD_ID__c, ServiceResource__r.StaffNumber__c,
                                ServiceResource__r.Service_Territory__r.Name, ServiceResource__r.Service_Territory__r.WCID__c, ServiceResource__r.Service_Territory__r.classify__c 
                                FROM Collaborator__c  
                                WHERE WorkOrder__c =:recordId];       

                for (Collaborator__c record : collaboratorList) {
                    WorkerInfoWrapper getRecord = new WorkerInfoWrapper();
                    getRecord.Id              = record.ServiceResource__c;
                    getRecord.Name            = record.ServiceResource__r.Name;
                    getRecord.workerPartnerNumber   = record.ServiceResource__r.StaffNumber__c;
                    getRecord.workCenterCode        = record.ServiceResource__r.Service_Territory__r.WCID__c;
                    getRecord.workCenterName        = record.ServiceResource__r.Service_Territory__r.Name;
                    getRecord.workCenterDivision    = record.ServiceResource__r.Service_Territory__r.classify__c;
                    workerInfoList.add(getRecord);
                }         

                List<WorkOrder> workOrderWorkers  = [SELECT Id, Worker__c, Worker__r.Name, Worker__r.Service_Territory__r.Name, Worker__r.AD_ID__c, Worker__r.StaffNumber__c,
                                                    Worker__r.Service_Territory__r.WCID__c, Worker__r.Service_Territory__r.classify__c, Worker__r.Service_Territory__c
                                                    FROM WorkOrder  
                                                    WHERE Id =:recordId];

                for (WorkOrder record : workOrderWorkers) {
                    WorkerInfoWrapper getRecord = new WorkerInfoWrapper();
                    getRecord.Id              = record.Worker__c;
                    getRecord.Name            = record.Worker__r.Name;
                    getRecord.workerPartnerNumber   = record.Worker__r.StaffNumber__c;
                    getRecord.workCenterCode        = record.Worker__r.Service_Territory__r.WCID__c;
                    getRecord.workCenterName        = record.Worker__r.Service_Territory__r.Name;
                    getRecord.workCenterDivision    = record.Worker__r.Service_Territory__r.classify__c;
                    workerInfoList.add(getRecord);
                }                               

                resMap.put('workerInfoList', workerInfoList);
                resMap.put('flag', 'success');
            } else if (type == 'InstallTest') {
                collaboratorList = [
                    SELECT Id, Name, ServiceResource__c, ServiceResource__r.Name,
                           ServiceResource__r.StaffNumber__c,
                           ServiceResource__r.Service_Territory__r.WCID__c,
                           ServiceResource__r.Service_Territory__r.Name,
                           ServiceResource__r.Service_Territory__r.classify__c
                    FROM Collaborator__c
                    WHERE WorkOrder__c = :recordId
                ];
                for (Collaborator__c record : collaboratorList) {
                    workerInfoList.add(new WorkerInfoWrapper(
                        record.ServiceResource__c,
                        record.ServiceResource__r.Name,
                        record.ServiceResource__r.StaffNumber__c,
                        record.ServiceResource__r.Service_Territory__c,
                        record.ServiceResource__r.Service_Territory__r.WCID__c,
                        record.ServiceResource__r.Service_Territory__r.Name,
                        record.ServiceResource__r.Service_Territory__r.classify__c
                    ));
                }
            
                WorkOrder wo = [SELECT ServiceTerritoryId FROM WorkOrder WHERE Id = :recordId LIMIT 1];
            
                if (wo.ServiceTerritoryId != null) {
                    List<ServiceResource> srList = [
                        SELECT Id, Name, AD_ID__c, StaffNumber__c,
                               Service_Territory__r.WCID__c,
                               Service_Territory__r.Name,
                               Service_Territory__r.classify__c
                        FROM ServiceResource
                        WHERE Service_Territory__c = :wo.ServiceTerritoryId
                    ];
                    for (ServiceResource sr : srList) {
                        workerInfoList.add(new WorkerInfoWrapper(
                            sr.Id,
                            sr.Name,
                            sr.StaffNumber__c,
                            sr.Service_Territory__c,
                            sr.Service_Territory__r.WCID__c,
                            sr.Service_Territory__r.Name,
                            sr.Service_Territory__r.classify__c
                        ));
                    }
                }
            
                resMap.put('workerInfoList', workerInfoList);
                resMap.put('flag', 'success');
            } else if (type == 'DNSA') {
                List<ServiceResource> workers  = [SELECT Id, Name, Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.WCID__c, 
                                                        Service_Territory__r.classify__c, Service_Territory__r.ControlWorkcenter__c, AD_ID__c, StaffNumber__c
                                                        FROM ServiceResource 
                                                        WHERE Service_Territory__c =:recordId];
                for (ServiceResource record : workers) {
                    WorkerInfoWrapper getRecord = new WorkerInfoWrapper();
                    getRecord.Id                    = record.Id;
                    getRecord.Name                  = record.Name;
                    getRecord.workerPartnerNumber   = record.StaffNumber__c;
                    getRecord.workCenterId          = record.Service_Territory__c;
                    getRecord.workCenterCode        = record.Service_Territory__r.WCID__c;
                    getRecord.workCenterName        = record.Service_Territory__r.Name;
                    getRecord.workCenterDivision    = record.Service_Territory__r.classify__c;
                    workerInfoList.add(getRecord);
                }               
                    resMap.put('workerInfoList', workerInfoList);
                    resMap.put('flag', 'success');                                    
            } else {
                List<ServiceResource> notBranchWorkers  = [SELECT Id, Name, Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.WCID__c, 
                                                        Service_Territory__r.classify__c, Service_Territory__r.ControlWorkcenter__c, AD_ID__c, StaffNumber__c
                                                        FROM ServiceResource 
                                                        WHERE Service_Territory__c =: recordId];

                for (ServiceResource record : notBranchWorkers) {
                    WorkerInfoWrapper getRecord = new WorkerInfoWrapper();
                    getRecord.Id                    = record.Id;
                    getRecord.Name                  = record.Name;
                    getRecord.workerPartnerNumber   = record.StaffNumber__c;
                    getRecord.workCenterId          = record.Service_Territory__c;
                    getRecord.workCenterCode        = record.Service_Territory__r.WCID__c;
                    getRecord.workCenterName        = record.Service_Territory__r.Name;
                    getRecord.workCenterDivision    = record.Service_Territory__r.classify__c;
                    workerInfoList.add(getRecord);
                }               
                    resMap.put('workerInfoList', workerInfoList);
                    resMap.put('flag', 'success');
            }
            
            if(workerInfoList.isEmpty()) {
                resMap.put('workerInfoList', '');
                resMap.put('flag','warning');
                return resMap;
            }

            if (Test.isRunningTest() && recordId == 'testException') {
                throw new AuraHandledException('Exception for testing');
            }
        } catch (Exception e) {
            System.debug('Error in getLoginUserInfo: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 워크센터 조회
    **/
    @AuraEnabled
    public static Map<String, Object> getCurruntWorkCenter(String workCenterId) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<ServiceTerritory> resultList = new List<ServiceTerritory>();
        
        try {
            if (String.isBlank(workCenterId)) {
                resMap.put('flag', 'warning');
                resMap.put('message', 'Invalid Work Center ID.');
                return resMap;
            }
            ServiceTerritory targetRecord = [SELECT Id, ControlWorkcenter__c, classify__c, WCCode__c FROM ServiceTerritory WHERE Id = :workCenterId LIMIT 1];

            if (targetRecord == null) {
                resMap.put('flag', 'error');
                resMap.put('message', 'No record found for the given ID.');
                return resMap;
            }

            if (targetRecord.classify__c == '지사') {
                resultList = [
                    SELECT Id, Name, ControlWorkcenter__c, WCCode__c, classify__c
                    FROM ServiceTerritory 
                    WHERE Id = :workCenterId 
                    OR ControlWorkcenter__c = :workCenterId
                ];
            } else if (targetRecord.classify__c == 'W/C') {
                resultList = [
                    SELECT Id, Name, ControlWorkcenter__c, WCCode__c, classify__c
                    FROM ServiceTerritory 
                    WHERE ControlWorkcenter__c = :targetRecord.ControlWorkcenter__c 
                    OR Id = :workCenterId 
                    OR ControlWorkcenter__c = :workCenterId
                ];
            } else {
                resMap.put('flag', 'warning');
                resMap.put('message', 'Unsupported Division value.');
                return resMap;
            }
            
            resMap.put('workCenterList', resultList);
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error in getCurrentWorkCenter: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }

        return resMap;
    }

    /**
    * @description 워크센터 선택시 선택된 워크센터의 작업자 리스트 반환
    **/
    @AuraEnabled
    public static Map<String, Object> getNewWorkers(String workCenterId) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<WorkerInfoWrapper> workerInfoList = new List<WorkerInfoWrapper>();
        
        try {
            if (Test.isRunningTest() && workCenterId == 'testException') {
                throw new AuraHandledException('Exception for testing');
            }

            if (String.isBlank(workCenterId)) {
                resMap.put('flag', 'warning');
                resMap.put('message', 'Invalid Work Center ID.');
                return resMap;
            }
            List<ServiceResource> resultList = [SELECT
                        Id, Name, RelatedRecordId, Service_Territory__c, Service_Territory__r.WCID__c, Service_Territory__r.Name, Service_Territory__r.classify__c, CurrentStatus__c
                        FROM ServiceResource  WHERE Service_Territory__c = :workCenterId];
            
            for (ServiceResource record : resultList) {
                WorkerInfoWrapper getRecord = new WorkerInfoWrapper();
                getRecord.Id              = record.Id;
                getRecord.Name            = record.Name;
                getRecord.workerPartnerNumber   = '';
                getRecord.workCenterId          = record.Service_Territory__c;
                getRecord.workCenterCode        = record.Service_Territory__r.WCID__c;
                getRecord.workCenterName        = record.Service_Territory__r.Name;
                getRecord.workCenterDivision    = record.Service_Territory__r.classify__c;
                workerInfoList.add(getRecord);
            } 

            resMap.put('newWorkerList', workerInfoList);
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error in getCurrentWorkCenter: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }

        return resMap;
    }
    
    /**
    * @description 납품후교육생성에서 사용하는 모달
    * @author daewook.kim@sbtglobal.com | 04-30-2025 
    * @param String erpNo 
    * @param String delaerAccId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> searchOrderList(String erpNo, String delaerAccId){
        Map<String, Object> resMap  = new Map<String, Object>();
        List<WorkOrder> workOrderList  = new List<WorkOrder>();
        List<Map<String, String>> resultList = new List<Map<String, String>>();
        User currentUser = [SELECT Id, Name, UserRole.Name, Profile.Name, SalesOffice__c, AccountId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        system.debug('currentUser >>> ' +currentUser);
        system.debug('delaerAccId >>> ' +delaerAccId);
        system.debug('current AccId >> ' +currentUser.AccountId);

        String accId = delaerAccId == null ? currentUser.AccountId : delaerAccId;
        system.debug('accId >> ' +accId);
        try {            
            String searchKeyword = '%' + erpNo + '%';

            if(currentUser.Profile.Name.contains('직영')){
                for (Order o : [SELECT ERPPSONo__c, ShipTo_PSO__r.Name, Account.name, SOSerialNumber__c, SOSerialNumber__r.Name, SOSerialNumber__r.MachineName__c FROM Order WHERE ERPPSONo__c != null AND SOSerialNumber__c != null AND Owner__r.SalesOffice__c =: currentUser.SalesOffice__c AND ERPPSONo__c LIKE: searchKeyword ]) {
                    Map<String, String> tmpMap = new Map<String, String>();
                    tmpMap.put('psoNumber', o.ERPPSONo__c);
                    tmpMap.put('AccountName', o.Account.Name);
                    tmpMap.put('MachineName', o.SOSerialNumber__r.MachineName__c);
                    tmpMap.put('SerialNo', o.SOSerialNumber__r.Name);
                    resultList.add(tmpMap);
                }
            }else{
                for (Order o : [SELECT ERPPSONo__c, ShipTo_PSO__r.Name, Account.name, SOSerialNumber__c, SOSerialNumber__r.Name, SOSerialNumber__r.MachineName__c FROM Order WHERE ERPPSONo__c != null AND SOSerialNumber__c != null AND owner__r.AccountId =: accId AND ERPPSONo__c LIKE: searchKeyword ]) {
                    Map<String, String> tmpMap = new Map<String, String>();
                    tmpMap.put('psoNumber', o.ERPPSONo__c);
                    tmpMap.put('AccountName', o.Account.Name);
                    tmpMap.put('MachineName', o.SOSerialNumber__r.MachineName__c);
                    tmpMap.put('SerialNo', o.SOSerialNumber__r.Name);
                    resultList.add(tmpMap);
                }
            }
            resMap.put('size', resultList.size());
            resMap.put('resultList', resultList);
            resMap.put('flag', 'success');
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 서비스 이력 조회 (영업) 수주번호(주문번호) 조회
    * @author Chungwoo Lee | 12-20-2024 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> searchWorkOrderList(String workOrderNumber) {
        Map<String, Object>     resMap          = new Map<String, Object>();
        List<WorkOrder>    workOrderList  = new List<WorkOrder>();
        List<Map<String, String>> resultList = new List<Map<String, String>>(); 
        try {
            if (Test.isRunningTest() && workOrderNumber == 'testException') {
                throw new AuraHandledException('Exception for testing');
            }

            String searchKeyword = '%' + workOrderNumber + '%';
            
            for(Asset o : [SELECT  Id, Name, MachineName__c, Account.Name, Order__r.ERPPSONo__c, Order__r.ShipTo__r.Name FROM Asset WHERE Order__r.ERPPSONo__c LIKE :searchKeyword]){
                Map<String, String> tmpMap = new Map<String, String>();
                tmpMap.put('psoNumber', o.Order__r.ERPPSONo__c);
                tmpMap.put('AccountName', o.Account.Name == null ? o.Order__r.ShipTo__r.Name :o.Account.Name);
                tmpMap.put('MachineName', o.MachineName__c);
                tmpMap.put('SerialNo', o.Name);
                resultList.add(tmpMap);
            }

            resMap.put('size', resultList.size());
            resMap.put('resultList', resultList);
            resMap.put('flag', 'success');
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 서비스 이력 조회 고객사 검색 모달 (영업 포탈) 
    * @author Chungwoo Lee | 11-12-2024 
    * @param searchData 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> searchCustomer(Map<String, Object> searchData) {
        Map<String, Object>     resMap          = new Map<String, Object>();
        List<Account>           accountList     = new List<Account>();
        
        try {
            String accountName      = (String)searchData.get('accountName');
            String representative   = (String)searchData.get('representative');
            String address          = (String)searchData.get('address');

            String queryString = 'SELECT Id, Representative__c, Name, FM_Address__c, ShippingAddress, Phone, toLabel(Country__c), ' + 
                                 'RecordType.Name, CustomerCode__c, CreatedDate ' + 
                                 'FROM Account WHERE IsVirtualParent__c = false AND RecordType.Name !='+ '\'Dealer\'';
            
            List<String> whereString = new List<String>();
        
            if (String.isNotBlank(accountName)) {
                whereString.add('Name Like ' + '\'%'+ String.escapeSingleQuotes(accountName)+'%\'');
            }
            if (String.isNotBlank(representative)) {
                whereString.add('Representative__c = \'' + String.escapeSingleQuotes(representative) + '\'');
            }
            if (String.isNotBlank(address)) {
                whereString.add('FM_Address__c Like ' + '\'%' + String.escapeSingleQuotes(address) + '%\'');
            }
            if (!whereString.isEmpty()) {
                queryString += ' AND ' + String.join(whereString, ' AND ');
            }

            queryString += ' ORDER BY CreatedDate DESC LIMIT 2000';
            resMap.put('queryString', queryString);
            accountList = Database.query(queryString);
            
            if (accountList.isEmpty()) {
                resMap.put('flag', 'warning');
                return resMap;
            }
            resMap.put('accountList', accountList);
            resMap.put('flag', 'success');
        }
         catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 서비스 리포트 표준 공수 모달 Init 메소드
    * @author Chungwoo Lee | 12-20-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> initStandardHRList(String objectType, String modelCode) {
        Map<String, Object>     resMap          = new Map<String, Object>();
        
        try {
            List<DN_FailureAreaController.CustomSelectOption> result = new List<DN_FailureAreaController.CustomSelectOption>();
            result = DN_FailureAreaController.getFailureAreaMajor(objectType);
            List<ModelManager__c> modelManageList ;
            if (!result.isEmpty()) {
                modelManageList = [SELECT Id, Name FROM ModelManager__c WHERE ModelCode__c =:modelCode LIMIT 1];

                if (!modelManageList.isEmpty()) {
                    ModelManager__c modelManager = modelManageList[0];

                    List<Standard_HR__c> standardHRList = [SELECT
                                Id, OwnerId, IsDeleted, Name, FailureArea__c, StandardHourItem__c, IsActive__c, StandardWorkTime__c, StandardWorkForce__c, ModelManager__c, FM_Manager__c
                                FROM Standard_HR__c 
                                WHERE IsActive__c = true AND ModelManager__c =:modelManager.Id Order By FailureArea__c LIMIT 2000];

                    if(!standardHRList.isEmpty()) {
                        resMap.put('flag', 'success');
                        resMap.put('failureAreaList', result); 
                        resMap.put('modelManager', modelManager); 
                        resMap.put('standardHRList', standardHRList); 
                    }
                }

            } else {
                if (result.isEmpty()) {
                    resMap.put('flag', 'warning'); 
                    resMap.put('message', '해당 장비의 등록된 고장부위 값이 없습니다.');
                } else {
                    resMap.put('flag', 'warning'); 
                    resMap.put('message', 'No records found.');
                }
            } 
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getStackTraceString());
        }
        return resMap;
    }

    /**
    * @description 서비스 리포트 표준 공수 모달 handleChange 
    * @author Chungwoo Lee | 01-03-2025 
    **/
    @AuraEnabled
    public static Map<String, Object> getStandardHRbyfailureArea(String failureArea, String modelManagerId) {
        Map<String, Object>     resMap          = new Map<String, Object>();
        try {
            if (Test.isRunningTest() && failureArea == 'testException') {
                throw new AuraHandledException('Exception for testing');
            }

            List<Standard_HR__c> standardHRList = [SELECT
                            Id, OwnerId, IsDeleted, Name, FailureArea__c, StandardHourItem__c, IsActive__c, StandardWorkTime__c, StandardWorkForce__c, ModelManager__c, FM_Manager__c
                            FROM Standard_HR__c 
                            WHERE IsActive__c = true AND ModelManager__c =:modelManagerId AND FailureArea__c =:failureArea ];
            if (standardHRList.isEmpty()) {
                resMap.put('flag', 'warning');
            } else {
                resMap.put('flag', 'success');
                resMap.put('standardHRList', standardHRList); 
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getStackTraceString());
        }
        return resMap;
    }

    /**
    * @description 서비스 리포트 표준 공수 조회 모달
    * @author Chungwoo Lee | 12-20-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> searchStandardHRList(String failureArea, String modelManagerId, String standardHourName) {
        Map<String, Object>     resMap          = new Map<String, Object>();
        List<Standard_HR__c>    standardHRList  = new List<Standard_HR__c>();
        
        try {
            if (Test.isRunningTest() && failureArea == 'testException') {
                throw new AuraHandledException('Exception for testing');
            }

            standardHRList = [SELECT
                                Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, FailureArea__c, StandardHourItem__c, IsActive__c, StandardWorkTime__c, StandardWorkForce__c, 
                                ModelManager__c, FM_Manager__c, ModelManager__r.ModelCode__c
                                FROM Standard_HR__c 
                                WHERE IsActive__c = true AND ModelManager__c =:modelManagerId AND FailureArea__c =:failureArea AND StandardHourItem__c =:standardHourName
                                ];
        
            if (standardHRList.isEmpty()) {
                resMap.put('flag', 'warning');
                return resMap;
            }
            resMap.put('standardHRList', standardHRList);
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }
        return resMap;
    }
    



/* ------------------------------------------------------------------------------------------------------------------------------------------- */
/* ----------------------------------------------------------------Asset Modal---------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------------------------------- */

    /**
    * @description 사용자가 입력한 내용을 바탕으로 기종(machine) 검색
    * @author Daewook.KIM | 11-06-2024 
    * @param String machineName 
    * @return List<Asset> 
    **/
    @AuraEnabled
    public static List<ModelManager__c> machineInfo(String machineName){
        try {
            System.debug('Search Machine Name');
            System.debug('userId :: ' + machineName);

            String mId = '%'+machineName+'%';
            List<ModelManager__c> machineList = new List<ModelManager__c>();
            machineList = [SELECT Id, Name, ModelCode__c FROM ModelManager__c WHERE Name Like:mId];
            System.debug('machineList : ' +machineList);

            return machineList;

        } catch (Exception e) {
            System.debug('error message :: ' + e.getMessage());
            System.debug('error line :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

  /**
    * @description 사용자가 선택한 machineName이 딸려있는 unitName 만 찾음.
    * @author Daewook.KIM | 11-06-2024 
    * @param String mn 
    * @return List<Asset> 
    **/
    @AuraEnabled
    public static List<Asset> unitInfo(String mn){
        try {
            System.debug('mn : '+mn);

            String baseQuery = 'SELECT Id, MachineName__c, Name FROM Asset WHERE MachineName__c != null AND MachineName__c = :mn';

            List<Asset> unitNumber = Database.query(baseQuery);
            
            System.debug('unitNumber : ' +unitNumber);

            return unitNumber;

        } catch (Exception e) {
            System.debug('error message :: ' + e.getMessage());
            System.debug('error line :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 장비번호 검색 모달
    * @author Daewook.KIM | 11-14-2024 
    * @param String mn 
    * @param String en 
    * @return List<Asset> 
    **/
    @AuraEnabled
    public static List<Asset> equipmentInfo(String mn, String en){
        try {
            System.debug('mn : '+mn);
            System.debug('en : '+en);

            String baseQuery = 'SELECT Id, MachineName__c, Name FROM Asset WHERE MachineName__c != null';

            if (mn != null && mn.trim() !='') {
                String searchMachine = '%'+mn+'%';
                system.debug('장비번호 모달 의 기종 searchMachine ::' + searchMachine);
                baseQuery += ' AND MachineName__c Like :searchMachine';
            }

            if (en != null && en.trim() !='') {
                String searchName = '%'+en+'%';
                system.debug('장비번호 모달 의 장비번호 searchMachine ::' + searchName);
                baseQuery += ' AND Name Like :searchName';
            }
            // 25.01.22 장비번호 검색시 LIMIT 추가 _ 김대욱
            baseQuery += ' LIMIT 50';

            System.debug('query ' +baseQuery);
            // 쿼리 실행
            List<Asset> unitNumber = Database.query(baseQuery);
            
            System.debug('unitNumber : ' +unitNumber);

            return unitNumber;

        } catch (Exception e) {
            System.debug('error message :: ' + e.getMessage());
            System.debug('error line :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 납품후교육생성화면에서 사용하는 모달
    * @author daewook.kim@sbtglobal.com | 04-30-2025 
    * @param String mn 
    * @param String en 
    * @param String delaerAccId 
    * @return List<Order> 
    **/
    @AuraEnabled
    public static List<Order> OrderEquipmentInfo(String mn, String en, String delaerAccId){
        try {
            System.debug('mn : '+mn);
            System.debug('en : '+en);

            String strQuery = 'SELECT ERPPSONo__c, ShipTo_PSO__r.Name, Account.name, SOSerialNumber__c, SOSerialNumber__r.Name, SOSerialNumber__r.MachineName__c '
            + ' FROM Order '
            + ' WHERE ERPPSONo__c != null '
            + ' AND SOSerialNumber__c != null '
            + ' AND owner__r.AccountId =: delaerAccId ';

            if (mn != null && mn.trim() !='') {
                String searchMachine = '%'+mn+'%';
                system.debug('장비번호 모달 의 기종 searchMachine ::' + searchMachine);
                strQuery += ' AND SOSerialNumber__r.MachineName__c Like :searchMachine';
            }

            if (en != null && en.trim() !='') {
                String searchName = '%'+en+'%';
                system.debug('장비번호 모달 의 장비번호 searchMachine ::' + searchName);
                strQuery += ' AND SOSerialNumber__r.Name Like :searchName';
            }

            System.debug('query ' +strQuery);

            List<Order> unitNumber = Database.query(strQuery);
            System.debug('unitNumber : ' +unitNumber);

            return unitNumber;

        } catch (Exception e) {
            System.debug('error message :: ' + e.getMessage());
            System.debug('error line :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 전체 딜러 목록(아직 필드 등이 명확하지 않아 최소 정보만 가져옴)
    * @author Daewook.KIM | 11-06-2024 
    * @return List<Account> 
    **/
    @AuraEnabled
    public static List<Account> getDealerInfo(){
        try {
            
            String userId = System.UserInfo.getUserId();
            System.debug('userId :: ' + userId);

            List<Account> dealerList = new List<Account>();
            dealerList = [
                SELECT Id, Name 
                FROM Account
                WHERE RecordType.Name = 'Dealer'
                ];
            System.debug('dealerList : ' +dealerList);

            return dealerList;

        } catch (Exception e) {
            System.debug('error message :: ' + e.getMessage());
            System.debug('error line :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

/* ------------------------------------------------------------------------------------------------------------------------------------------- */
/* ----------------------------------------------------------------Parts Modal---------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------------------------------- */


    /**
    * @description 부품 정보 조회.
    * @author Daewook.KIM | 11-12-2024 
    * @param String partCode 
    * @param String partName 
    * @return List<Product2> 
    **/
    @AuraEnabled
    public static List<Product2> getPartsInfo(String partCode, String partName, List<String> partList, Boolean isDNSA){
        try {   
            String code;
            String name;

            List<String> conditions = new List<String>();
            String plantCheck = '';

            if (partCode != null && partCode.trim() != '') {
                code = partCode + '%';
                conditions.add('ProductCode LIKE :code');
            }

            if (partName != null && partName.trim() != '') {
                name = partName + '%';
                //25.01.07 제품명 필드 변경
                conditions.add('FM_MaterialDetails__c LIKE :name');
            }

            // DNSA 서비스 리포트에서 부품 조회하는 경우 추가 조건 2025.05.22 이청우
            if (isDNSA != null && isDNSA == true) {
                plantCheck = ('(Plant__c LIKE \'%4146%\' OR Plant__c LIKE \'%414S%\')');
            }
            
            String baseQuery = 'SELECT Id, Name, FM_MaterialDetails__c, ProductCode, RecordTypeId, Model__c, IsStrategicMaterial__c, Replacement__c FROM Product2';
            if (!conditions.isEmpty()) {
                baseQuery += ' WHERE (' + String.join(conditions, ' OR ') + ')'; // OR 조건문 괄호 추가 2025.03.25 이청우
            }

            // DNSA 서비스 리포트에서 부품 조회하는 경우 추가 조건 2025.05.22 이청우
            if (String.isNotBlank(plantCheck)) {
                if (baseQuery.contains('WHERE')) {
                    baseQuery += ' AND ' + plantCheck;
                } else {
                    baseQuery += ' WHERE ' + plantCheck;
                }
            }

            // 기존 검색 제외해야할 부품 목록이 있는 경우 제외 처리 2025. 02. 11 - 서일태
            // WHERE절 조건 부 추가 2025.03.25 이청우
            if (partList.size() > 0) {
                if (baseQuery.contains('WHERE')) {
                    baseQuery += ' AND Id NOT IN (\'' + String.join(partList, '\',\'') + '\')';
                } else {
                    baseQuery += ' WHERE Id NOT IN (\'' + String.join(partList, '\',\'') + '\')';
                }
            }

            System.debug(baseQuery + '::baseQuery');
            // 2024 12 31 서일태
            // 부품이 많아서 조회시 Limit 추가 및 RecordType 조건 추가
            // WHERE절 조건 부 추가 2025.03.25 이청우
            if (baseQuery.contains('WHERE')) {
                baseQuery += ' AND RecordType.DeveloperName = \'Part\' LIMIT 2000';
            } else {
                baseQuery += ' WHERE RecordType.DeveloperName = \'Part\' LIMIT 2000';
            }

            System.debug('final QueryText ::: ' + baseQuery);

            // 쿼리 실행
            List<Product2> partsInfo = Database.query(baseQuery);
            System.debug('partsInfo :: '+partsInfo);

            return partsInfo;
            
        } catch (Exception e) {
            System.debug('error message :: ' + e.getMessage());
            System.debug('error line :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

/* -------------------------------------------------------------------------------------------------------------------------------------------- */
/* --------------------------------------------------------------Buyer Info Modal-------------------------------------------------------------- */
/* -------------------------------------------------------(DN_AgencyCustomerShipToModal)------------------------------------------------------- */    

    @AuraEnabled
    public static List<DealerCustomerShipTo__c> searchBuyerInfo(String bc, String bn, DN_PortalLoginUser.DealerInfo dli){
        try {
            System.debug('buyerCode : '+bc);
            System.debug('buyerName : '+bn);
            System.debug('DealerInfo : '+dli);

            String dc = dli.dealerCode;
            String dp = dli.userProfile;
            String ac = dli.accountId;

            System.debug('dealerCode : '+dc);
            System.debug('dealerProfile : '+dp);

            // 권한으로 조건을 걸어놔서 따로 조건이 없어도 해당하는 것만 쿼리 됨.
            String query = 'SELECT FM_Customer__c, FM_CustomerCode__c, IsDealer__c,DealerCode__c,Customer__c, Customer__r.CustomerCode__c, FM_Address__c, RoadAddr__c, DetailInfo__c, '
                            +'Customer__r.FM_PartsManagerName__c, Customer__r.FM_PartsManagerPhone__c, Address__c,Customer__r.Dealer__r.CustomerCode__c '
                            +'FROM DealerCustomerShipTo__c '
                            +'WHERE Id != null ';

            if (String.isNotBlank(bc)) {
                query += 'AND FM_CustomerCode__c Like ' + '\'%'+bc+'%\' ';
            }

            if (String.isNotBlank(bn)) {
                query += 'AND FM_Customer__c Like ' + '\'%'+bn+'%\' ';
            }

            query += ' AND Customer__r.IsActive__c = true';
            query += ' ORDER BY FM_CustomerCode__c ASC';
            query += ' LIMIT 30000';
            system.debug('query str :: ' +query);
            List<DealerCustomerShipTo__c> buyerInfo = Database.query(query);
            system.debug('buyerInfo >>>>>>' + buyerInfo);

            List<DealerCustomerShipTo__c> addressList = new List<DealerCustomerShipTo__c>();
            Map<String,DealerCustomerShipTo__c> shipMap = new Map<String,DealerCustomerShipTo__c>();
            for(DealerCustomerShipTo__c dealer: buyerInfo) {
                if(dealer.IsDealer__c) {
                    addressList.add(dealer);
                } else {
                    if(String.isNotBlank(dealer.DealerCode__c)) {
                        if(dealer.DealerCode__c ==currentUser.getAgencyCustomerCode()) {
                            addressList.add(dealer);
                    	}
                    } else {
                        if(dealer.Customer__r.Dealer__r.CustomerCode__c ==currentUser.getAgencyCustomerCode()) {
                            addressList.add(dealer);
                        }
                    }
                }
                
            }
            System.debug(addressList + ':::addressList');
            system.debug('buyerInfo :: '+buyerInfo);
            return addressList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* -------------------------------------------------------(DN_AgencyCustomerShipToModal)------------------------------------------------------- */    
    /* ------------------------------------------------------------ 대리점 주문, DNS 구매 ----------------------------------------------------------- */    
    @AuraEnabled
    public static List<DN_AgencyCustomerListModalController.AgencyCustomerShipTo> getDealerCustomerShipTo(String customerCode, String customerName){
        try {
            List<DN_AgencyCustomerListModalController.AgencyCustomerShipTo> shipToList = new List<DN_AgencyCustomerListModalController.AgencyCustomerShipTo>();

            shipToList = DN_AgencyCustomerListModalController.getCustomerShipTos(customerCode, customerName);

            return shipToList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}