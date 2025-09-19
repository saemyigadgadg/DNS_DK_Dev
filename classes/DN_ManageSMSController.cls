/**
* @Class : DN_SendSMSController
*
* @Author : Hayeong, Min
* @Date : 2024. 05. 31.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-05-31 | Hayeong, Min   | 최초작성
*
*/
public with sharing class DN_ManageSMSController {
    /*
     * @Description
     * 	- 서비스 WorkCenter List 출력
     *  
     */ 
    @AuraEnabled
    public static Map<String, List<PicklistWrapper>> getWorkCenterList(){
        Map<String, List<PicklistWrapper>> resultMap = new Map<String, List<PicklistWrapper>>();
        List<PicklistWrapper> stPick = new List<PicklistWrapper>();
        stPick.add(new PicklistWrapper('전체', 'all'));
        List<PicklistWrapper> wcPick = new List<PicklistWrapper>();
        wcPick.add(new PicklistWrapper('전체', 'all'));

        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('SMSHistory__c') ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('SendTargetList__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        try {
            List<ServiceTerritory> wcList = [SELECT Id, Name FROM ServiceTerritory WHERE PlanningPlant__c = '184S' AND IsActive = true ORDER BY Name ASC];
            for(ServiceTerritory obj : wcList) {
                wcPick.add(new PicklistWrapper(obj.name, obj.Id));
            }

            for( Schema.PicklistEntry pickListVal : ple){
                stPick.add(new PicklistWrapper(pickListVal.getLabel(), pickListVal.getValue()));
            }
            resultMap.put('stPick', stPick);
            resultMap.put('wcPick', wcPick);
        } catch (Exception e) {
            System.debug('Exception Error : ' + e.getMessage());
        }
        return resultMap;
    }

    /*
     * @Description
     * 	- 해당 WorkCenter에 속한 출동직원 출력
     * 
     * @Parameter
     *  - recordID	    : Service Territory의 Id
     */ 
    @AuraEnabled
    public static List<PicklistWrapper> getStaffList(String recordID){
        List<PicklistWrapper> wcPick = new List<PicklistWrapper>();
        wcPick.add(new PicklistWrapper('전체', 'all'));
        System.debug('workCenter : '+ recordID);
        String query = 'SELECT Id, Name FROM ServiceResource ';

        try {
            if(String.isNotEmpty(recordID)){
                query += 'WHERE Service_Territory__c = \''+ recordID+'\'';
                query += ' ORDER BY Name ASC';
                List<ServiceResource> wcList = Database.query(query);
                for(ServiceResource obj : wcList) {
                    wcPick.add(new PicklistWrapper(obj.name, obj.Id));
                }
            }
        } catch (Exception e) {
            System.debug('Exception Error : ' + e.getMessage());
        }
        return wcPick;
    }

    /*
     * @Description
     * 	- 조건에 맞는 출동직원 리스트 출력
     * 
     * @Parameter
     *  - searchKey	    : 검색어
     */ 
    @AuraEnabled
    public static List<SMSWrapper> getSMSList(String searchKey) {
        System.debug('searchKey: ' + searchKey);
        List<SMSWrapper> sms = new List<SMSWrapper>();
        List<SMSHistory__c> sh = new List<SMSHistory__c>();
        Map<String, Object> searchKeyJSON = (Map<String, Object>) JSON.deserializeUntyped(searchKey);
    
        String startDate = String.valueOf(searchKeyJSON.get('startDate'));
        String endDate = String.valueOf(searchKeyJSON.get('endDate'));
        String searchTarget = String.valueOf(searchKeyJSON.get('searchTarget'));
        String serviceResourceId = String.valueOf(searchKeyJSON.get('serviceResourceId'));
        String accountId = String.valueOf(searchKeyJSON.get('accountId'));
        String workOrderId = String.valueOf(searchKeyJSON.get('workOrderId'));
        System.debug('startDate: ' + startDate);
        System.debug('endDate: ' + endDate);
        System.debug('searchTarget: ' + searchTarget);
        System.debug('serviceResourceId: ' + serviceResourceId);
        System.debug('accountId: ' + accountId);
        System.debug('workOrderId: ' + workOrderId);
    
        String query = 'SELECT Id, Owner.Name, InboundCall__c, OutBoundCall__c, ';
        query += 'WorkOrder__c, WorkOrder__r.WorkOrderNumber, ServiceResource__c, ServiceResource__r.StaffNumber__c, ServiceResource__r.Name, ';
        query += 'Asset__c, Asset__r.Name, Asset__r.MachineName__c, Account__c, Account__r.Name, SendTargetPickVal__c, Content__c, CreatedDate FROM SMSHistory__c ';
        // if(String.valueOf(searchKeyJSON.get('searchTarget')) != 'all'){
        //     query += ' AND SendTargetPickVal__c = \''+String.valueOf(searchKeyJSON.get('searchTarget'))+'\' ';
        // }
        // if(String.isNotEmpty(String.valueOf(searchKeyJSON.get('serviceResourceId')))){
        //     query += ' AND ServiceResource__c = \''+String.valueOf(searchKeyJSON.get('serviceResourceId'))+'\' ';
        // }
        // if(String.isNotEmpty(String.valueOf(searchKeyJSON.get('accountId')))){
        //     query += ' AND Account__c = \''+String.valueOf(searchKeyJSON.get('accountId'))+'\' ';
        // }
        // if(String.isNotEmpty(String.valueOf(searchKeyJSON.get('workOrderId')))){
        //     query += ' AND WorkOrder__c = \''+String.valueOf(searchKeyJSON.get('workOrderId'))+'\' ';
        // }
        // WHERE 절 구성
        List<String> filters = new List<String>();
    
        // 날짜 입력이 있을 경우 CreatedDate 범위 추가
        if (String.isNotBlank(startDate) && String.isNotBlank(endDate)) {
            filters.add('DAY_ONLY(CreatedDate) >= ' + startDate + ' AND DAY_ONLY(CreatedDate) <= ' + endDate);
        }
    
        // 검색 조건 추가
        if (String.isNotBlank(searchTarget) && searchTarget != 'all') {
            filters.add('SendTargetPickVal__c = :searchTarget');
        }
        if (String.isNotBlank(serviceResourceId) && serviceResourceId != '()') {
            filters.add('ServiceResource__c = :serviceResourceId');
        }
        if (String.isNotBlank(accountId) && accountId != '()') {
            filters.add('Account__c = :accountId');
        }
        if (String.isNotBlank(workOrderId) && workOrderId != '()') {
            filters.add('WorkOrder__c = :workOrderId');
        }
    
        // WHERE 절 적용
        if (!filters.isEmpty()) {
            query += 'WHERE ' + String.join(filters, ' AND ');
        }
    
        try {
            sh = Database.query(query);
            for (SMSHistory__c s : sh) {
                SMSWrapper sw = new SMSWrapper();
                sw.OwnerName = s.Owner.Name;
                sw.InboundCall = s.InboundCall__c;
                sw.OutboundCall = s.OutBoundCall__c;
                sw.OrderNumber = s.WorkOrder__r.WorkOrderNumber;
                sw.MachineName = s.Asset__r.MachineName__c;
                sw.SerialNumber = s.Asset__r.Name;
                sw.StaffId = s.ServiceResource__r.StaffNumber__c;
                sw.Staff = s.ServiceResource__r.Name;
                sw.Account = s.Account__r.Name;
                sw.SendTargetPickVal = s.SendTargetPickVal__c;
                sw.Content = s.Content__c;
                sw.RegisterDate = s.CreatedDate.date();
                sw.RegisterTime = s.CreatedDate.format('HH:mm:ss');
                sms.add(sw);
            }
        } catch (Exception e) {
            System.debug('Exception Error: ' + e.getMessage());
        }
        System.debug(query);
        return sms;
    }
    


    /*
     * @Description
     * 	- 조건에 맞는 출동직원 리스트 출력
     * 
     * @Parameter
     *  - workCenter	    : 서비스 W/C
     *  - dispatchStaff	    : 출동직원
     */ 
    @AuraEnabled
    public static List<StaffWrapper> getSearchList(String workCenter, String dispatchStaff){
        List<StaffWrapper> sw = new List<StaffWrapper>();

        try {
            //List<ServiceResource> wcList = [SELECT Id, Name, Service_Territory__r.Name, PhoneNumber__c, StaffNumber__c FROM ServiceResource];
            //wcList query 조건 더 걸어야 함
            List<ServiceResource> wcList = new List<ServiceResource>();
            String query = 'SELECT Id, Name, Service_Territory__r.Name, PhoneNumber__c, StaffNumber__c FROM ServiceResource WHERE IsActive = true AND Branch__c = \'DNS\'';

            System.debug(workCenter);
            System.debug(dispatchStaff);
            
            if(workCenter != 'all' && dispatchStaff == 'all'){
                query += 'AND Service_Territory__c = \''+ workCenter + '\' ';
            }else if(workCenter != 'all' && dispatchStaff != 'all'){
                query += 'AND Service_Territory__c = \''+ workCenter + '\' ';
                query += 'AND Id = \''+ dispatchStaff + '\' ';
            }

            wcList = Database.query(query);
            for(ServiceResource obj : wcList) {
                StaffWrapper data = new StaffWrapper();
                data.Id = obj.Id;
                data.WorkCenter = obj.Service_Territory__r.Name;
                data.StaffId = obj.StaffNumber__c;
                data.StaffName = obj.Name;
                data.Phone = obj.PhoneNumber__c;
                data.isChecked = false;
                sw.add(data);
            }
        } catch (Exception e) {
            System.debug('Exception Error : ' + e.getMessage());
        }
        return sw;
    }


    @AuraEnabled
    public static ResultWrapper sendSMSConfirm(String sendInfo) {
        System.debug('sendInfo:::' + sendInfo);
        ResultWrapper rw = new ResultWrapper();
        try {
            String outboundNum = '';
            String inboundNum = '';
            String smsContent = '';
            Map<String, Object> sendInfoJSON = (Map<String, Object>) JSON.deserializeUntyped(sendInfo);
            List<Object> sendInfoArr = (List<Object>) sendInfoJSON.get('selectedList');
            
            if (String.isNotEmpty((String) sendInfoJSON.get('smsContent'))) {
                smsContent = (String) sendInfoJSON.get('smsContent');
            }
            if (String.isNotEmpty((String) sendInfoJSON.get('outboundNum'))) {
                outboundNum = (String) sendInfoJSON.get('outboundNum');
            }
            if (String.isNotEmpty((String) sendInfoJSON.get('inboundNum'))) {
                inboundNum = (String) sendInfoJSON.get('inboundNum');
            }

            List<IF_BIZ_SMS.T_SMS_DATA> smsList = new List<IF_BIZ_SMS.T_SMS_DATA>();
            List<SMSHistory__c> smsHistoryList = new List<SMSHistory__c>();

            for (Object obj : sendInfoArr) {
                Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                System.debug(data.get('Phone'));

                IF_BIZ_SMS.T_SMS_DATA sms = new IF_BIZ_SMS.T_SMS_DATA();
                sms.TRAN_PHONE = (String) data.get('Phone');
                sms.TRAN_CALLBACK = outboundNum;
                sms.TRAN_MSG = smsContent;			
                sms.TRAN_ETC1 = 'CRM';
                smsList.add(sms);

                // SMSHistory__c 저장 로직 추가
                SMSHistory__c newSmsHistory = new SMSHistory__c();
                newSmsHistory.OutBoundCall__c = outboundNum;
                newSmsHistory.InboundCall__c = (String) data.get('Phone');
                newSmsHistory.Content__c = smsContent;
                newSmsHistory.SendTargetPickVal__c = '서비스요원';
                newSmsHistory.ServiceResource__c = (String) data.get('Id');  
                newSmsHistory.Account__c = (String) data.get('AccountId');
                newSmsHistory.WorkOrder__c = (String) data.get('WorkOrderId');
                smsHistoryList.add(newSmsHistory);
            }
            
            // 만약 inboundNum이 있다면 추가로 저장
            if (inboundNum != null) {
                IF_BIZ_SMS.T_SMS_DATA sms = new IF_BIZ_SMS.T_SMS_DATA();
                sms.TRAN_PHONE = inboundNum;
                sms.TRAN_CALLBACK = outboundNum;
                sms.TRAN_MSG = smsContent;			
                sms.TRAN_ETC1 = 'CRM';
                smsList.add(sms);

                SMSHistory__c inboundSmsHistory = new SMSHistory__c();
                inboundSmsHistory.OutBoundCall__c = outboundNum;
                inboundSmsHistory.InboundCall__c = inboundNum;
                inboundSmsHistory.Content__c = smsContent;
                // inboundSmsHistory.SendTargetPickVal__c = '서비스요원';
                smsHistoryList.add(inboundSmsHistory);
            }

            IF_BIZ_SMS.DICCSAP_SEND_SMS_WP send = new IF_BIZ_SMS.DICCSAP_SEND_SMS_WP();
            send.DICCSAP_SEND_SMS_M(smsList);

            // SMS 기록 저장
            if (!smsHistoryList.isEmpty()) {
                insert smsHistoryList;
                System.debug('smsHistoryList:::' + smsHistoryList);
            }

            rw.isSuccess = true;
        } catch (Exception e) {
            rw.isSuccess = false;
            rw.errMessage = e.getMessage();
            System.debug('Error in sendSMSConfirm: ' + e.getMessage());
        }
        return rw;
    }


    /*
     * @Description 
     *  - StaffWrapper Wrapper
     * 
     * @Variable 
     *  - Id		        : Service Resource ID
     *  - WorkCenter		: 서비스 W/C
     *  - StaffId 	        : 서비스요원 ID
     *  - StaffName    		: 서비스요원명
     *  - Phone 		    : 전화번호
     *  - isChecked 		: 선택유무
     * 
     */ 
    public class StaffWrapper{
        @AuraEnabled public String Id 	            { get;set; }
        @AuraEnabled public String WorkCenter 		{ get;set; }
        @AuraEnabled public String StaffId 		    { get;set; }
        @AuraEnabled public String StaffName 		{ get;set; }
        @AuraEnabled public String Phone 	        { get;set; }
        @AuraEnabled public Boolean isChecked 	    { get;set; }
    }


    // PickList Setting Wrapper
    public class PicklistWrapper {
        @AuraEnabled public String label  {get;set;}
        @AuraEnabled public String value  {get;set;}
        public PicklistWrapper(String Label, String Value) {
            this.label = Label;
            this.value = Value;
        }
    }

    /*
     * @Description 
     *  - Apex Callout 실행 결과용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - errMessage 	: 실패 시 에러메세지 
     */ 
    public class ResultWrapper{
        @AuraEnabled public Boolean isSuccess  { get; set;}
        @AuraEnabled public String  errMessage { get; set;}

        public ResultWrapper(){
            this.isSuccess = true;
        }
    }


    public class SMSWrapper{
        @AuraEnabled public String OwnerName 	            { get;set; }
        @AuraEnabled public String InboundCall 		        { get;set; }
        @AuraEnabled public String OutboundCall 		    { get;set; }
        @AuraEnabled public String OrderNumber 		        { get;set; }
        @AuraEnabled public String MachineName 	            { get;set; }
        @AuraEnabled public String SerialNumber 	        { get;set; }
        @AuraEnabled public String StaffId 	                { get;set; }
        @AuraEnabled public String Staff 	                { get;set; }
        @AuraEnabled public String Account 	                { get;set; }
        @AuraEnabled public String SendTargetPickVal 	    { get;set; }
        @AuraEnabled public String Content 	                { get;set; }
        @AuraEnabled public Date RegisterDate 	            { get;set; }
        @AuraEnabled public String RegisterTime 	        { get;set; }
    }
}