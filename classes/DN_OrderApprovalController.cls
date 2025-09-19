/**
 * @related           : dN_OrderApprovalRelatedList
 * @description       : Order의 승인 관련 정보, 버튼, 상태를 표시할 컴포넌트 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-02-18   yeongju.yun   Initial Version
**/
public with sharing class DN_OrderApprovalController {
    public static DN_OrderService ordSvc = new DN_OrderService();

    /**
    * @description 주문에 연결 된 승인 히스토리 조회
    **/
    @AuraEnabled
    public static ResultWrapper initRelatedList(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {

            Order order = [
                SELECT  Id, Status, OwnerId, Owner__r.internal_approver__c, OpportunityId
                        , ApprovalStatus__c, toLabel(ApprovalStatus__c) apvStatus
                        , IsOpportunityClosed__c, Opportunity.StageName
                FROM    Order
                WHERE   Id =: recordId
            ];

            Boolean hasOpty = order.OpportunityId != null;
            if(hasOpty) {

                result.data.put('isOptyClosed', order.IsOpportunityClosed__c);
                result.data.put('optyStageName', ordSvc.getPicklistLabel('Opportunity', 'StageName', order.Opportunity.StageName));
                
                OpportunityStage optyStage = [
                    SELECT  Id, SortOrder, ApiName
                    FROM    OpportunityStage 
                    WHERE   IsActive = true
                    AND     ApiName =: order.Opportunity.StageName
                    ORDER BY SortOrder
                ];
    
                Decimal optyStageOrder = optyStage.ApiName.contains('Closed') ? 5 : optyStage.SortOrder;
                result.data.put('optyStageOrder', optyStageOrder);
            }
            result.data.put('hasOpty', hasOpty);

            // card info
            result.data.put('title', order.get('apvStatus'));
            result.data.put('icon', 'standard:approval');

            // column label
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('OrderApproval__c').getDescribe().fields.getMap();
            Map<String, String> fieldInfo = new Map<String, String>();
            for(Schema.SObjectField field : fieldMap.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                fieldInfo.put(fieldDescribe.getName(), fieldDescribe.getLabel());
            }
            result.data.put('fieldInfo', fieldInfo);

            List<String> hideBtnList = new List<String>{ordSvc.ORDER_CREATE, ordSvc.ORDER_PROGRESS};
            Boolean hideBtn = !hideBtnList.contains(order.Status);

            // base data
            result.data.put('status', order.ApprovalStatus__c);
            result.data.put('isManager', ordSvc.isManager(order.OwnerId));
            result.data.put('isAdmin', ordSvc.getAdminFlag());
            result.data.put('isApprover', order.Owner__r.internal_approver__c == UserInfo.getUserId());
            result.data.put('isOwner', order.OwnerId == UserInfo.getUserId());
            result.data.put('isCRMUser', ordSvc.IS_USER);
            result.data.put('hideBtn', hideBtn);

            // prev data
            List<OrderApproval__c> approvals = [
                SELECT  Id, Status__c, StepName__c
                        , Requester__c, Requester__r.Name, RequestDate__c, RequesterComments__c
                        , Approver__c, Approver__r.Name, DecisionDate__c, ApproverComments__c
                FROM    OrderApproval__c
                WHERE   Order__c =: recordId
                ORDER BY CreatedDate DESC
            ];

            Boolean isUser = ordSvc.IS_USER;
            String baseUrl = ordSvc.getBaseUrl(!isUser);

            List<TableWrapper> tableWrapList = new List<TableWrapper>();
            for(OrderApproval__c apv : approvals){
                TableWrapper tableWrap = new TableWrapper(apv, baseUrl);
                tableWrapList.add(tableWrap);
            }
            if(!tableWrapList.isEmpty()) {
                result.data.put('tableWrapList', tableWrapList);
            }
            
            return result;
        } catch (Exception e) {
            System.debug('initRelatedList ERROR ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 승인 진행 전 Validate
    **/
    @AuraEnabled
    public static ResultWrapper validateApproval(String recordId, Boolean isWorkerRule){
        ResultWrapper result = new ResultWrapper();

        try {
            Order order = [
                SELECT  Id, Status, IsOwnerWorker__c, ApprovalStatus__c, HasPricingProcessed__c
                        , HasScheduleCompleted__c, IsOpportunityClosed__c, SalesChannelType__c, ERPOrderNo__c
                FROM    Order 
                WHERE   Id =: recordId
            ];

            Boolean isDomestic = ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c);

            List<PaymentSchedule__c> psList = [SELECT Id, DraftCheck__c FROM PaymentSchedule__c WHERE Order__c =: recordId];

            List<OrderPricingSelected__c> orderSelecteds = [SELECT Id FROM OrderPricingSelected__c WHERE Order__c =: recordId];

            // worker only
            if(isWorkerRule && order.Status != ordSvc.ORDER_CREATE) {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_InternalApprovalCreate; // Internal approval can only be processed in the 'Order Create' status.
            }

            // manager only
            else if(!isWorkerRule && String.isNotBlank(order.ERPOrderNo__c)){
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_AlreadyRequested; // This order has already been requested for confirmation.
            }
            
            // common
            else if(!order.IsOpportunityClosed__c) {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_OpportunityClosed; // Please close the opportunity first.
            }

            else if(isDomestic && !order.HasScheduleCompleted__c) {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_CompletePaymentSchedule; // Please complete the payment schedule first.
            }

            else if(isDomestic && !orderSelecteds.isEmpty() && psList[0].DraftCheck__c != 'Success') {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_ValidationDraftNo; // Validation is required to ensure that the Draft No is valid.
            }
            return result;

        } catch (Exception e) {
            System.debug('validateApproval error ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 내부 승인 진행 및 히스토리 생성
    **/
    @AuraEnabled
    public static ResultWrapper doInternalApproval(String recordId, String comments){
        ResultWrapper result = new ResultWrapper();
        SavePoint sp = Database.setSavePoint();
        try {

            User u = [SELECT Id, Name, internal_approver__c FROM User WHERE Id =:UserInfo.getUserId()];

            // insert order approval
            OrderApproval__c appv     = new OrderApproval__c();
            appv.Order__c             = recordId;
            appv.Status__c            = ordSvc.APPROVALSTATUS_PENDING;
            appv.StepName__c          = ordSvc.STEPNAME_INTERNAL;
            appv.Requester__c         = UserInfo.getUserId();
            appv.RequestDate__c       = Date.today();
            appv.RequesterComments__c = comments ?? '';
            appv.Approver__c          = u.internal_approver__c;
            insert appv;

            // update order
            Order order = [SELECT Id, Status, ApprovalStatus__c, OwnerId, SoldTo__c, SoldTo__r.Name, ShipTo__c, ShipTo__r.Name, OrderNumber FROM Order WHERE Id =: recordId];

            order.Status            = ordSvc.ORDER_PROGRESS;
            order.ApprovalStatus__c = ordSvc.APPROVAL_INTERNALREQUESTED;
            update order;

            Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
            targetUserMap.put(order.Id, new Set<Id>{appv.Approver__c});

            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'OrderRequestApproval'
                , 'bell'
                , new List<Order>{order}
                , targetUserMap
                , new Map<String, Object>{
                    'userNameMap'  => new Map<Id, String>{recordId => UserInfo.getName()}
                    , 'nameMap'    => new Map<Id, String>{recordId => appv.RequesterComments__c}
                    , 'accNameMap' => new Map<Id, String>{order.SoldTo__c => order.SoldTo__r.Name, order.ShipTo__c => order.ShipTo__r.Name}
                }
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                result.isSuccess  = false;
                result.errMessage = bellAlertResult.errMessage;
            }

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'OrderRequestApproval'
                , 'email'
                , new List<Order>{order}
                , targetUserMap
                , new Map<String, Object>{
                    'userNameMap'  => new Map<Id, String>{recordId => UserInfo.getName()}
                    , 'nameMap'    => new Map<Id, String>{recordId => appv.RequesterComments__c}
                    , 'accNameMap' => new Map<Id, String>{order.SoldTo__c => order.SoldTo__r.Name, order.ShipTo__c => order.ShipTo__r.Name}
                }
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                result.isSuccess  = false;
                result.errMessage = emailAlertResult.errMessage;
            }
            
            return result;
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('doInternalApproval ERROR ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 승인 반려, 주문에 상태 업데이트, 히스토리 생성
    **/
    @AuraEnabled
    public static ResultWrapper rejectApproval(String recordId, String comments){
        ResultWrapper result = new ResultWrapper();
        SavePoint sp = Database.setSavePoint();
        try {

            List<OrderApproval__c> appvList = [
                SELECT  Id, Status__c, DecisionDate__c, ApproverComments__c, Requester__c, Approver__r.Name
                FROM    OrderApproval__c 
                WHERE   Order__c =: recordId 
                AND     Status__c =: ordSvc.APPROVALSTATUS_PENDING
            ];

            if(!appvList.isEmpty()) {
                OrderApproval__c appv    = appvList[0];
                appv.Status__c           = ordSvc.APPROVALSTATUS_REJECTED;
                appv.DecisionDate__c     = Date.today();
                appv.ApproverComments__c = comments ?? '';
                update appv;

                Order order = [SELECT Id, Status, ApprovalStatus__c, OwnerId, OrderNumber FROM Order WHERE Id =: recordId];

                order.Status            = ordSvc.ORDER_CREATE;
                order.ApprovalStatus__c = ordSvc.APPROVAL_REJECTED;
                update order;

                Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
                targetUserMap.put(order.Id, new Set<Id>{appv.Requester__c});

    
                UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                    'OrderInternalRejected'
                    , 'bell'
                    , new List<Order>{order}
                    , targetUserMap
                    , new Map<String, Object>{
                        'userNameMap'  => new Map<Id, String>{recordId => appv.Approver__r.Name}
                        , 'nameMap'    => new Map<Id, String>{recordId => appv.ApproverComments__c}
                    }
                );
                if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                    result.isSuccess  = false;
                    result.errMessage = bellAlertResult.errMessage;
                }
    
                UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                    'OrderInternalRejected'
                    , 'email'
                    , new List<Order>{order}
                    , targetUserMap
                    , new Map<String, Object>{
                        'userNameMap'  => new Map<Id, String>{recordId => appv.Approver__r.Name}
                        , 'nameMap'    => new Map<Id, String>{recordId => appv.ApproverComments__c}
                    }
                );
                if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                    result.isSuccess  = false;
                    result.errMessage = emailAlertResult.errMessage;
                }
            }

            return result;
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('rejectApproval ERROR ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 승인 시 알림 발송 및 히스토리 생성
    **/
    @AuraEnabled
    public static ResultWrapper approveApproval(String recordId, String comments, Boolean isApprove){
        ResultWrapper result = new ResultWrapper();
        SavePoint sp = Database.setSavePoint();
        try {
            List<OrderApproval__c> appvList = [
                SELECT  Id, Status__c, DecisionDate__c, ApproverComments__c, Requester__c, Approver__r.Name
                FROM    OrderApproval__c 
                WHERE   Order__c =: recordId 
                AND     Status__c =: ordSvc.APPROVALSTATUS_PENDING
            ];

            Order order  = [SELECT Id, Status, ApprovalStatus__c, OwnerId, OrderNumber FROM Order WHERE Id =: recordId];
            if(isApprove && !appvList.isEmpty()) {

                OrderApproval__c appv    = appvList[0];
                appv.Status__c           = ordSvc.APPROVALSTATUS_APPROVED;
                appv.DecisionDate__c     = Date.today();
                appv.ApproverComments__c = comments ?? '';
                update appv;

                Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
                targetUserMap.put(order.Id, new Set<Id>{appv.Requester__c});

                UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                    'OrderInternalApproved'
                    , 'bell'
                    , new List<Order>{order}
                    , targetUserMap
                    , new Map<String, Object>{
                        'userNameMap'  => new Map<Id, String>{recordId => appv.Approver__r.Name}
                        , 'nameMap'    => new Map<Id, String>{recordId => appv.ApproverComments__c}
                    }
                );
                if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                    result.isSuccess  = false;
                    result.errMessage = bellAlertResult.errMessage;
                }
    
                UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                    'OrderInternalApproved'
                    , 'email'
                    , new List<Order>{order}
                    , targetUserMap
                    , new Map<String, Object>{
                        'userNameMap'  => new Map<Id, String>{recordId => appv.Approver__r.Name}
                        , 'nameMap'    => new Map<Id, String>{recordId => appv.ApproverComments__c}
                    }
                );
                if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                    result.isSuccess  = false;
                    result.errMessage = emailAlertResult.errMessage;
                }
            }

            OrderApproval__c newAppv = new OrderApproval__c();
            newAppv.Order__c         = recordId;
            newAppv.Status__c        = ordSvc.APPROVALSTATUS_PENDING;
            newAppv.StepName__c      = ordSvc.STEPNAME_ERP;
            newAppv.Requester__c     = UserInfo.getUserId();
            newAppv.RequestDate__c   = Date.today();
            insert newAppv;

            order.ApprovalStatus__c = ordSvc.APPROVAL_CONFIRMREQUESTED;
            order.Status = ordSvc.ORDER_PROGRESS;
            order.IF_FreePass__c  = true;
            update order;

            return result;

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('approveApproval ERROR ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 결과 반환 wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  {get;set;}
        @AuraEnabled public String  errMessage {get;set;}

        @AuraEnabled public Map<String, Object> data {get;set;}
        
        public ResultWrapper(){
            this.isSuccess  = true;
            this.errMessage = '';
            this.data = new Map<String, Object>();
        }
    }

    /**
    * @description 승인 이력 wrapper
    **/
    public class TableWrapper {
        @AuraEnabled public String recordId {get;set;}
        @AuraEnabled public String status   {get;set;}
        @AuraEnabled public String stepName {get;set;}

        @AuraEnabled public String requester  {get;set;}
        @AuraEnabled public Date requestDate  {get;set;}
        @AuraEnabled public String requestCmt {get;set;}

        @AuraEnabled public String approver    {get;set;}
        @AuraEnabled public Date decisionDate  {get;set;}
        @AuraEnabled public String approverCmt {get;set;}

        @AuraEnabled public String link {get;set;}

        public TableWrapper(){}
        public TableWrapper(OrderApproval__c apv, String baseURL){
            this.recordId = apv.Id;
            this.status   = apv.Status__c;
            this.stepName = apv.StepName__c;

            this.requester   = apv.Requester__r.Name;
            this.requestDate = apv.RequestDate__c;
            this.requestCmt  = apv.RequesterComments__c;

            this.approver     = apv.Approver__r.Name;
            this.decisionDate = apv.DecisionDate__c;
            this.approverCmt  = apv.ApproverComments__c;

            this.link = baseURL + '/' + this.recordId;
        }
    }

    /**
    * @description 가격정보 wrapper
    **/
    public class PriceWrapper{
        public String  posnr    {get;set;}
        public Decimal price    {get;set;}
        public Decimal tax      {get;set;}
        
        public PriceWrapper(){}
    }
}