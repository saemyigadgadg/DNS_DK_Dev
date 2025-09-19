/**
* @Class : DN_StandardMHApprovalController
*
* @Author : Junyeong, Choi
* @Date : 2024. 12. 10.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-12-10 | Junyeong, Choi | ver. 1
*  2. | 2025-03-06 | Junyeong, Choi | ver. 2 표준공수 요청목록 추가
* 
*/
public with sharing class DN_StandardMHApprovalController {

    /**
     * @Description
     * 	- Get 표준공수 요청목록
     * @Return
     *  - RequestWrapper
    **/
    @AuraEnabled
    public static List<RequestWrapper> getRequestList(String orderNumber, Date startDate, Date endDate, Id modelManager, String selectedStatus){
        System.debug('startDate => ' + startDate);
        System.debug('endDate => ' + endDate);

        List<RequestWrapper> wrappers = new List<RequestWrapper>();
        List<RequestStandardHR__c> requestList = new List<RequestStandardHR__c>();
        String sQuery = 'SELECT Id, Name, FaultArea__c, StandardHourItem__c, Requester__c, Requester__r.Name,StandardWorkTime__c, OrderNo__c, StandardWorkForce__c, StandardHour__c, BeforeWorkTime__c, BeforeWorkForce__c, ' +
                        'RequestReason__c, Approver__c, Approver__r.Name, RequestType__c, ApprovalStatus__c, RejectReason__c, CreatedDate, ServiceOrder__c, ServiceOrder__r.WorkOrderNumber FROM RequestStandardHR__c';
        List<String> wQuery = new List<String>();

        // Order Number Filter
        if (orderNumber != null && orderNumber.trim() != '') {
            wQuery.add('OrderNo__c LIKE \'%' + orderNumber + '%\'');
        }
        
        // 요청일시 날짜 Filter
            Datetime fromDate = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);
            Datetime toDate = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 23, 59, 59);            
            wQuery.add('CreatedDate >= :fromDate AND CreatedDate <= :toDate');
            
        // 기종담당자 Filter
        if (modelManager != null) {
            wQuery.add('Approver__c = \'' + modelManager + '\'');
        }

        // 표준공수 변경요청 상태 Filter
        if (selectedStatus == '승인') {
            wQuery.add('ApprovalStatus__c = \'승인\'');
        } else if (selectedStatus == '반려') {
            wQuery.add('ApprovalStatus__c = \'반려\'');
        } else if (selectedStatus == '승인대기') {
            wQuery.add('ApprovalStatus__c = \'승인대기\'');
        }
        
        if(!wQuery.isEmpty()) {
            sQuery += ' WHERE ' + String.join(wQuery, ' AND ');
        }
        System.debug('sQuery => ' + sQuery);

        String oQuery = ' ORDER BY CreatedDate DESC';
        requestList = Database.query(sQuery + oQuery);
        System.debug('requestList => ' + requestList);

        for(RequestStandardHR__c obj : requestList) {
            RequestWrapper wrapper      = new RequestWrapper();
            wrapper.Id                  = obj.Id;
            wrapper.standardHour        = obj.StandardHour__c;
            wrapper.orderNumber         = obj.OrderNo__c;
            wrapper.failureArea         = obj.FaultArea__c;
            wrapper.standardHourItem    = obj.StandardHourItem__c;
            wrapper.requester           = obj.Requester__r.Name;
            wrapper.standardHourTime    = obj.BeforeWorkTime__c;
            wrapper.standardHourForce   = obj.BeforeWorkForce__c;
            wrapper.changeNeed          = obj.RequestType__c;
            wrapper.realWorkTime        = obj.StandardWorkTime__c;
            wrapper.realWorkForce       = obj.StandardWorkForce__c;
            wrapper.requestReason       = obj.RequestReason__c;
            wrapper.modelManager        = obj.Approver__r.Name;
            wrapper.requestStatus       = obj.ApprovalStatus__c;
            wrapper.rejectReason        = obj.RejectReason__c;
            wrappers.add(wrapper);
        }
        System.debug('wrappers => ' + wrappers);
        return wrappers;
    }

    // 표준공수 승인확인
    @AuraEnabled
    public static ResultWrapper confirmApproval(String requesterData){
        System.debug('requesterData'+requesterData);
        ResultWrapper rw = new ResultWrapper();
        List<UTIL_Alert.HistoryWrapper> notiList = new List<UTIL_Alert.HistoryWrapper>();
        String alertManager = [SELECT Id FROM AlertManager__c WHERE Name = 'CS StandardMH Approve Noti' LIMIT 1].Id;
        try {
            Map<String, Object> requesterDataInfo = (Map<String, Object>) JSON.deserializeUntyped(requesterData);
            
            List<Standard_HR__c> shrList = 
            [
                SELECT Id, Name, FailureArea__c, StandardHourItem__c, IsActive__c, StandardWorkTime__c, StandardWorkForce__c, ModelManager__c, FM_Manager__c, ModelCode__c
                FROM Standard_HR__c
                WHERE Id =: String.valueOf(requesterDataInfo.get('standardHour'))
            ];

            Standard_HR__c shr;
            if(shrList.size() > 0) {
                shr = shrList[0];
            }
            
            RequestStandardHR__c rshr = 
            [
                SELECT Id, Name, CreatedDate, RequestReason__c, ApprovalStatus__c, RequestType__c, FaultArea__c, 
                RejectReason__c, Requester__c, Approver__c, StandardWorkTime__c, StandardWorkForce__c, ModelManager__c, 
                StandardHour__c, StandardHourItem__c, ServiceOrder__c, BeforeWorkTime__c, BeforeWorkForce__c
                FROM RequestStandardHR__c
                WHERE Id =: String.valueOf(requesterDataInfo.get('Id'))
            ];
            System.debug('RequestStandardHR =>' + rshr);

            if(rshr.RequestType__c == '변경') {
                shr.StandardWorkTime__c    = rshr.StandardWorkTime__c;
                shr.StandardWorkForce__c   = rshr.StandardWorkForce__c;
                rshr.ApprovalStatus__c     = '승인';
                update new List<SObject>{ shr, rshr };

            } else if(rshr.RequestType__c == '신규') {
                Standard_HR__c newSH = new Standard_HR__c();
                newSH.IsActive__c            =   true;
                newSH.StandardWorkTime__c    =   rshr.StandardWorkTime__c;
                newSH.StandardWorkForce__c   =   rshr.StandardWorkForce__c;
                newSH.FailureArea__c         =   rshr.FaultArea__c;
                newSH.ModelManager__c        =   rshr.ModelManager__c;
                newSH.StandardHourItem__c    =   rshr.StandardHourItem__c;
                insert newSH;

                rshr.ApprovalStatus__c     = '승인';
                update rshr;
            }

            if(rshr.Requester__c != null) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(rshr.Name);
                history.alertID         = alertManager;
                history.targetID        = rshr.Id;
                history.receiverforID   = new Set<Id>{rshr.Requester__c};
                history.alertLanguage   = 'ko';
                notiList.add(history);
                System.debug('notiList'+notiList);
                UTIL_Alert.runAlertEvent(notiList);
            }
        } catch (Exception e) {
            rw.isSuccess = false;
            rw.errMessage = e.getMessage();
        }
        return rw;
    }

    // 표준공수 승인반려
    @AuraEnabled
    public static ResultWrapper confirmReject(String requesterData, String rejectReason){
        System.debug('requesterData'+requesterData);
        ResultWrapper rw = new ResultWrapper();
        List<UTIL_Alert.HistoryWrapper> notiList = new List<UTIL_Alert.HistoryWrapper>();
        String alertManager = [SELECT Id FROM AlertManager__c WHERE Name = 'CS StandardMH Reject Noti' LIMIT 1].Id;
        try {
            Map<String, Object> requesterDataInfo = (Map<String, Object>) JSON.deserializeUntyped(requesterData);           
            RequestStandardHR__c rshr = 
            [
                SELECT Id, Name, CreatedDate, RequestReason__c, ApprovalStatus__c, RequestType__c, FaultArea__c, 
                RejectReason__c, Requester__c, Approver__c, StandardWorkTime__c, StandardWorkForce__c, ModelManager__c, 
                StandardHour__c, StandardHourItem__c, ServiceOrder__c, BeforeWorkTime__c, BeforeWorkForce__c
                FROM RequestStandardHR__c
                WHERE Id =: String.valueOf(requesterDataInfo.get('Id'))
            ];
            System.debug('RequestStandardHR =>' + rshr);

            rshr.RejectReason__c     = rejectReason;
            rshr.ApprovalStatus__c   = '반려';
            update rshr;

            if(rshr.Requester__c != null) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(rshr.Name);
                history.alertID         = alertManager;
                history.targetID        = rshr.Id;
                history.receiverforID   = new Set<Id>{rshr.Requester__c};
                history.alertLanguage   = 'ko';
                notiList.add(history);
                System.debug('notiList'+notiList);
                UTIL_Alert.runAlertEvent(notiList);
            }

        } catch (Exception e) {
            rw.isSuccess = false;
            rw.errMessage = e.getMessage();
        }
        return rw;
    }

    /*
     * @Description 
     *  - Apex Callout 실행 결과용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - errMessage 	: 실패 시 에러메세지 
     */ 
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  { get; set;}
        @AuraEnabled public String  errMessage { get; set;}
        
        public ResultWrapper(){
            this.isSuccess = true;
        }
    }

    /*
     * @Description 
     *  - 표준공수 요청목록 Wrapper
     */ 

     public class RequestWrapper {
        @AuraEnabled public String Id                   { get; set;}
        @AuraEnabled public String standardHour         { get; set;}
        @AuraEnabled public String orderNumber          { get; set;}
        @AuraEnabled public String failureArea          { get; set;}
        @AuraEnabled public String standardHourItem     { get; set;}
        @AuraEnabled public String requester            { get; set;}
        @AuraEnabled public Decimal standardHourTime    { get; set;}
        @AuraEnabled public Decimal standardHourForce   { get; set;}
        @AuraEnabled public String changeNeed           { get; set;}
        @AuraEnabled public Decimal realWorkTime        { get; set;}
        @AuraEnabled public Decimal realWorkForce       { get; set;}
        @AuraEnabled public String requestReason        { get; set;}
        @AuraEnabled public String modelManager         { get; set;}
        @AuraEnabled public String requestStatus        { get; set;}
        @AuraEnabled public String rejectReason         { get; set;}

        public RequestWrapper() {
            this.Id                  = '';
            this.standardHour        = '';
            this.orderNumber         = '';
            this.failureArea         = '';
            this.standardHourItem    = '';
            this.requester           = '';
            this.standardHourTime    = 0;
            this.standardHourForce   = 0;
            this.changeNeed          = '';
            this.realWorkTime        = 0;
            this.realWorkForce       = 0;
            this.requestReason       = '';
            this.modelManager        = '';
            this.requestStatus       = '';
            this.rejectReason        = '';
        }
    }
}