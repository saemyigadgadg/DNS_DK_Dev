/**
 * @related           : [DN_PreparationNewBtn, DN_PreparationEditBtn]
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-05-07   yeongju.yun   EDIT01. 에러 개선, 중복 확인 시 쿼리 쉐어링 제외
**/
public with sharing class DN_PreparationFormController {

    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description serial number가 있는지, 기존에 생성 된 사전설치 점검표는 없는지 확인
    * @author yeongju.yun | 2024-11-04 
    * @param parentId 
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper checkCreatePermission(String parentId){
        ResultWrapper result = new ResultWrapper();

        Id tempId = Id.valueOf(parentId);
        String objName = tempId.getSObjectType().getDescribe().getName();
        
        try {
            
            if(objName == 'Order') {

                List<Order> orderList = [SELECT Id, Status, SerialNumber__c, SOSerialNumber__c FROM Order WHERE Id =: parentId];

                WITHOUTWrapper wrap = new WITHOUTWrapper();

                List<PreparationChecklist__c> prevPreList = wrap.queryPrevPreparation(parentId);
                if(String.isBlank(orderList[0].SerialNumber__c) || orderList[0].SOSerialNumber__c == null) {
                    result.isPass   = false;
                    result.errorMsg = System.Label.DNS_M_PreparationCreationError; 
                    // The Preparation Checklist cannot be created without an SO serial number.
                } else if(!prevPreList.isEmpty()) {
                    result.isPass   = false;
                    result.errorMsg = System.Label.DNS_OnlyOnePreparationChecklist; 
                    // Only one Preparation Checklist can be created per order. If there are changes, please update the existing Preparation Checklist.
                }
            }

            return result;
        } catch (Exception e) {
            System.debug('checkCreatePremission : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 수정 권한 유무 확인
    **/
    @AuraEnabled
    public static ResultWrapper checkEditPermission(String recordId){
        ResultWrapper result = new ResultWrapper();
        
        try {
            WITHOUTWrapper wrap = new WITHOUTWrapper();
            List<Case> ticketList = wrap.queryTicket(recordId);
            Boolean isPass = true;
            for(Case c : ticketList) {
                if(c.Status != ordSvc.TICKET_REJECT) { isPass = false; }
            }

            if(!isPass) {
                result.isPass   = false;
                result.errorMsg = System.Label.DNS_M_PreparationEditError; 
                // The Preparation Checklist can only be edited when the ticket status is 'Reject'.
            }

            return result;
        } catch (Exception e) {
            System.debug('checkCreatePremission : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 사전설치점검표 주문 기반 기본값 조회
    * @author yeongju.yun | 2024-11-04 
    * @param parentId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> getDefaultValues(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        WITHOUTWrapper wrap = new WITHOUTWrapper();
        try {

            Id tempId = Id.valueOf(recordId);
            String sObjName = tempId.getSObjectType().getDescribe().getName();
            Boolean isEdit = sObjName == 'PreparationCheckList__c';

            Id orderId = tempId;
            List<PreparationCheckList__c> preList;
            if(isEdit) {
                preList = wrap.queryPreparation(recordId);
                orderId = preList[0].Order__c;

                result.put('account',      preList[0].Account__c);
                result.put('contact',      preList[0].ContactPerson__c);
                result.put('salesRep',     preList[0].SalesReps__c);
            } 

            List<Order> orderList = [
                SELECT  Id, OwnerId, Owner__r.SalesOffice__c , Owner__r.AccountId, Owner__r.UserType, ShipTo__c, ShipTo_PSO__c
                FROM    Order
                WHERE   Id =: orderId
            ];

            // order owner의 같은 소속인 사람
            // 딜러일 때 > user의 accountid를 받아서 같은 accountid를 가진 user의 id
            // 영업일 때 > user의 salesoffice가 동일한 사람 (추가 조건 없는지 확인 필요)
            Boolean isUser = ordSvc.getUserFlag(orderList[0].Owner__r.UserType);
            List<User> userList = new List<User>();
            if(isUser) {
                userList = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND SalesOffice__c =: orderList[0].Owner__r.SalesOffice__c];
            } else {
                userList = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND AccountId =: orderList[0].Owner__r.AccountId];
            }

            List<OptionWrapper> uOptions = new List<OptionWrapper>();
            for(User u : userList) {
                uOptions.add(new OptionWrapper(u.Name, u.Id));
            }
            result.put('uOptions', uOptions);

            String contactParantId = isEdit ? String.valueOf(result.get('account')) : orderList[0].ShipTo_PSO__c;
            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE AccountId =: contactParantId];
            List<OptionWrapper> cOptions = new List<OptionWrapper>();
            for(Contact con : conList) {
                cOptions.add(new OptionWrapper(con.Name, con.Id));
            }
            result.put('cOptions', cOptions);

            result.put('shipTo', orderList[0].ShipTo_PSO__c);
            result.put('orderOwner', orderList[0].OwnerId);

            List<DeliveryOrder__c> doList = wrap.queryDO(orderId);
            if(!doList.isEmpty()) {
                result.put('delivery', doList[0].Id);
            }

            return result;
            
        } catch (Exception e) {
            System.debug('getDefaultValues : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Preparation Checlist에 들어갈 User의 소속을 저장하기 위함
    * @author yeongju.yun | 2024-11-06 
    * @param userIds 
    * @return Map<Id, String> 
    **/
    @AuraEnabled
    public static Map<Id, Id> getBelonging(List<Id> userIds){
        
        try {
            
            Map<Id, Id> result = ordSvc.getRelatedAccounts(new Set<Id>(userIds));
            return result;
            
        } catch (Exception e) {
            System.debug('getBelonging : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Contact정보 Option으로 변환
    **/
    @AuraEnabled
    public static List<OptionWrapper> getContactOption(String accountId){
        try {

            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE AccountId =: accountId];
            List<OptionWrapper> cOptions = new List<OptionWrapper>();
            for(Contact con : conList) {
                cOptions.add(new OptionWrapper(con.Name, con.Id));
            }
            return cOptions;

        } catch (Exception e) {
            System.debug('getContactOption : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 결과 반환 wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isPass   {get;set;}
        @AuraEnabled public String  errorMsg {get;set;}

        @AuraEnabled public Map<String, Object> data {get;set;}

        public ResultWrapper(){
            this.isPass   = true;
            this.errorMsg = '';
            this.data = new Map<String, Object>();
        }
    }

    /**
    * @description Picklist <-> Component Option 전환 wrapper
    **/
    public class OptionWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public OptionWrapper(){
            this.label = '';
            this.value = '';
        }

        public OptionWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    /**
    * @description Dealer권한 제한으로 Sharing과 무관하게 조회용 wrapper
    **/
    public without sharing class WITHOUTWrapper{
        public WITHOUTWrapper(){}

        public List<PreparationCheckList__c> queryPrevPreparation(String recordId) {
            return [SELECT Id FROM PreparationChecklist__c WHERE Order__c =: recordId];
        }

        public List<PreparationCheckList__c> queryPreparation(String recordId){
            return [
                SELECT  Id, Order__c, Account__c, ContactPerson__c, SalesReps__c
                FROM    PreparationChecklist__c 
                WHERE   Id =: recordId
            ];
        }

        public List<Case> queryTicket(String recordId) {
            return [SELECT Id, Status, PreparationChecklist__c FROM Case WHERE PreparationChecklist__c =: recordId];
        }

        public List<DeliveryOrder__c> queryDO(String recordId) {
            return [SELECT Id FROM DeliveryOrder__c WHERE Order__c = :recordId];
        }
    }

}