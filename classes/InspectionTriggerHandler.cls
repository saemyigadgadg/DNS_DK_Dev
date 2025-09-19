/**
 * @description       : 
 * @test              : InspectionTriggerHandlerTest
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-24-2024   Hanyeong Choi   Initial Version
**/
public with sharing class InspectionTriggerHandler extends TriggerHandler {

    public static DN_OrderService ordSvc = new DN_OrderService();

    public override void onBeforeInsert(List<sObject> news){
        if(isExecuting) {
            List<Inspection__c> inspectionList = (List<Inspection__c>) news;

            validateInspection(inspectionList);
            setQM(inspectionList);
            
            setting(false, TriggerOperation.BEFORE_INSERT);
        }
    }

    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting) {
            List<Inspection__c> inspectionList = (List<Inspection__c>) news;

            sendCreationNoti(inspectionList);
            
            setting(false, TriggerOperation.AFTER_INSERT);
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            List<Inspection__c>    inspectionList = (List<Inspection__c>) news;
            Map<Id, Inspection__c> inspectionMap  = (Map<Id, Inspection__c>) oldMap;

            List<Inspection__c> target = new List<Inspection__c>();
            for(Inspection__c ins : inspectionList) {
                if(inspectionMap.get(ins.Id).QualityConfirm__c == 'N' && ins.QualityConfirm__c == 'Y' ) {
                    target.add(ins);
                }
            }

            if(!target.isEmpty()) {
                addInspectionEvent(target, inspectionMap);
                sendNotiToDealer(target, inspectionMap);
            }

            setting(false, TriggerOperation.AFTER_UPDATE);
        }
    }

    /**
    * @description 입회검사 생성은 Order의 Status 'Order Confirmed' 부터 가능
                    + The end date of the visit cannot be earlier than the start date.
                    + The start date must be a future date and cannot be today or in the past.
    * @author yeongju.yun | 2024-10-31 
    * @param news 
    **/
    private void validateInspection(List<Inspection__c> news) {
        
        Set<Id> orderIdSet = new Set<Id>();
        for(Inspection__c ins : news) {
            orderIdSet.add(ins.Order__c);
        }

        List<Order> orderList = [SELECT Id, Status FROM Order WHERE Id =: orderIdSet];

        Map<Id, Boolean> orderConfirmedMap = new Map<Id, Boolean>();
        for(Order order : orderList) {
            orderConfirmedMap.put(order.Id, ordSvc.UPTO_PROGRESS.contains(order.Status));
        }

        TimeZone userTimeZone = UserInfo.getTimeZone();
        Datetime now = Datetime.now().addSeconds(userTimeZone.getOffset(Datetime.now()) / 1000);
        Datetime tomorrowStart = Datetime.newInstance(now.year(), now.month(), now.day()).addDays(1);

        for(Inspection__c ins : news) {
            if(orderConfirmedMap.get(ins.Order__c)) { ins.addError(System.Label.DNS_M_InspectionCreation); }
            // Inspection creation is only allowed starting from the 'Order Confirmed' status.
            else if(ins.Start_Date_of_Visit__c > ins.End_Date_of_Visit__c) { ins.addError(System.Label.DNS_M_InspectionDateError); }
            // The end date of the visit cannot be earlier than the start date.
            else if(ins.Start_Date_of_Visit__c < tomorrowStart) { ins.addError(System.Label.DNS_M_NoPastDate); }
            // The start date must be a future date and cannot be today or in the past.
        }
    }

    /**
    * @description 입회검사 생성 시 담당 품질팀 배정
    * @author yeongju.yun | 2024-10-31 
    * @param news 
    **/
    private void setQM(List<Inspection__c> news) {

        List<User> qmList = [SELECT Id, Name, Email FROM User WHERE IsActive = TRUE AND UserRole.DeveloperName =: ordSvc.QM];
        if(qmList.isEmpty()) {
            news[0].addError(System.Label.DNS_M_NoQMRep); // No available QM Representative for assignment.
        }

        for(Inspection__c ins : news) {
            ins.QMRep__c = qmList[0].Id;
        }
    }

    
    /**
    * @description 입회검사 생성 시 품질 계정으로 자동 Notification 발송
                   250120 입회검사 생성 시 Manager(국내 - 지사장, 해외 - 글로벌 영업)에게 Notification 발송
                   250310 DNSA 입회검사 생성 시 QM, Message Group (글로벌영업DNSA)
    * @author yeongju.yun | 2024-10-31 
    * @param news 
    **/
    private void sendCreationNoti(List<Inspection__c> news) {
        
        // separate the orders based on type.
        Set<Id> orderIdSet = new Set<Id>();
        for(Inspection__c ins : news) {
            orderIdSet.add(ins.Order__c);
        }

        // order number list
        List<Order> orderList = [SELECT Id, OrderNumber FROM Order WHERE Id =: orderIdSet];
        Map<Id, String> ordNameMap = new Map<Id, String>();
        for(Order order : orderList) {
            ordNameMap.put(order.Id, order.OrderNumber);
        }

        Map<String, Set<Id>> targetUserMap = setTargetUsers(news);

        UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
            'InspectionCreation'
            , 'bell'
            , news
            , targetUserMap
            , new Map<String, Object>{'ordNameMap' => ordNameMap}
        );
        if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){ news[0].addError(bellAlertResult.errMessage); }

        UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
            'InspectionCreation'
            , 'email'
            , news
            , targetUserMap
            , new Map<String, Object>{'ordNameMap' => ordNameMap}
        );
        if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){ news[0].addError(emailAlertResult.errMessage); }
    }

    /**
    * @description StartDate / EndDate기준으로 Event 생성하여 Calendar 등록
                   20250430 Event 추가 대상 확대 : DNS - ManagerId, DNSA - Message Group (글로벌영업DNSA)
    * @author yeongju.yun | 2024-10-31 
    * @param target 
    * @param oldMap 
    **/
    private void addInspectionEvent(List<Inspection__c> target, Map<Id, Inspection__c> oldMap) {

        Map<String, Set<Id>> relationMap = setTargetUsers(target);
        
        Set<Id> dnsOwnerIds = new Set<Id>();
        for(Inspection__c ins : target) {
            if(ins.F_OrderType__c != ordSvc.CHANNER_DNSA) dnsOwnerIds.add(ins.OwnerId);
        }

        Map<Id, Boolean> languageMap = new Map<Id, Boolean>();
        if(!dnsOwnerIds.isEmpty()) {
            List<User> users = [SELECT Id,LanguageLocaleKey FROM User WHERE Id =: dnsOwnerIds];
            for(User u : users) {
                languageMap.put(u.Id, u.LanguageLocaleKey == 'ko');
            }
        }

        List<Event> eventList = new List<Event>();
        for(Inspection__c ins : target) {
            
            DateTime startDateTime = ins.Start_Date_of_Visit__c;
            DateTime endDateTime   = ins.End_Date_of_Visit__c;
            Boolean isKorean       = ins.F_OrderType__c != ordSvc.CHANNER_DNSA;
            if(languageMap.containsKey(ins.OwnerId)) isKorean = languageMap.get(ins.OwnerId);

            while (startDateTime < endDateTime) { // An event can't last longer than 14 days.
                DateTime eventEndDateTime = startDateTime.addDays(13);
                if (eventEndDateTime > endDateTime) { eventEndDateTime = endDateTime; }

                String title = isKorean ? '입회검사' : 'FAT'; // System.Label.DNS_C_Inspection

                Event evt         = new Event();
                evt.Subject       = '[' + title + '] ' + ins.FM_CompanyName__c;
                evt.WhatId        = ins.Id;
                evt.StartDateTime = startDateTime;
                evt.EndDateTime   = eventEndDateTime;
                evt.OwnerId       = ins.OwnerId;
                eventList.add(evt);

                Date nextDate = eventEndDateTime.addDays(1).date();
                startDateTime = DateTime.newInstance(nextDate, Time.newInstance(0, 0, 0, 0));
            }
        }

        List<EventRelation> shareList = new List<EventRelation>();
        if(!eventList.isEmpty()){
            insert eventList; 

            for(Event evt : eventList) {
                Set<Id> userIdSet = relationMap.get(evt.WhatId);
                for(Id uId : userIdSet) {
                    if(uId == evt.OwnerId) continue;

                    EventRelation er = new EventRelation();
                    er.EventId       = evt.Id;
                    er.RelationId    = uId;
                    er.IsInvitee     = true;
                    shareList.add(er);
                }
            }
        }

        if(!shareList.isEmpty()) { insert shareList; }
    }

    /**
    * @description 주문의 Owner(딜러)에게 Notification
                   20250502 Noti 대상 확대 : DNS - ManagerId, DNSA - Message Group (글로벌영업DNSA)
    * @author yeongju.yun | 2024-11-01 
    * @param news 
    * @param oldMap 
    **/
    private void sendNotiToDealer(List<Inspection__c> news, Map<Id, Inspection__c> oldMap) {

        Set<Id> orderIdSet = new Set<Id>();
        for(Inspection__c ins : news) {
            orderIdSet.add(ins.Order__c);
        }

        List<Order> orderList = [SELECT Id, OrderNumber, OwnerId, Owner.Name FROM Order WHERE Id =: orderIdSet];
        
        Map<Id, String> userNameMap = new Map<Id, String>(); // key : order id, value : order number
        for(Order order : orderList) {
            userNameMap.put(order.Id, order.OrderNumber);
        }

        Map<String, Set<Id>> targetUserMap = setTargetUsers(news);

        UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
            'InspectionConfirmed'
            , 'bell'
            , news
            , targetUserMap
            , new Map<String, Object>{'userNameMap' => userNameMap}
        );
        if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){ news[0].addError(bellAlertResult.errMessage); }

        UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
            'InspectionConfirmed'
            , 'email'
            , news
            , targetUserMap
            , new Map<String, Object>{'userNameMap' => userNameMap}
        );
        if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){ news[0].addError(emailAlertResult.errMessage); }

    }

    /**
    * @description 이메일 수신 대상자 설정
    **/
    private Map<String, Set<Id>> setTargetUsers(List<Inspection__c> news) {
        // (DNSA)
        List<Message_Group_Junction__c> msgGroups = [
            SELECT  Id, Message_Group__c, User__c
            FROM    Message_Group_Junction__c
            WHERE   Message_Group__r.name = 'Global Sales (DNSA)'
        ];

        Set<Id> dnsaUsers = new Set<Id>();
        for(Message_Group_Junction__c msgJunction : msgGroups) {
            dnsaUsers.add(msgJunction.User__c);
        }

        // (QM)
        List<User> qmList = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND UserRole.DeveloperName = :ordSvc.QM];

        // (Owner)
        Set<Id> orderIds = new Set<Id>();
        Set<Id> dnsOwnerIds = new Set<Id>();
        for(Inspection__c ins : news) {
            orderIds.add(ins.Order__c);
            if(ins.F_OrderType__c != ordSvc.CHANNER_DNSA) dnsOwnerIds.add(ins.OwnerId);
        }

        // (Order Owner)
        List<Order> orderList = [SELECT Id, OwnerId FROM Order WHERE Id =: orderIds];
        Map<Id, Id> orderOwnerMap = new Map<Id, Id>(); // key : order id, value : order owner id
        for(Order order : orderList) {
            orderOwnerMap.put(order.Id, order.OwnerId);
        }

        // (DNS Manager)
        Map<Id, Id> insOwnerMap = new Map<Id, Id>(); // key : inspection owner id, value : owner manager id
        if(!dnsOwnerIds.isEmpty()) {
            List<User> users = [SELECT Id, ManagerId FROM User WHERE Id =: dnsOwnerIds AND ManagerId <> NULL];
            for(User u : users) {
                insOwnerMap.put(u.Id, u.ManagerId);
            }
        }

        Map<String, Set<Id>> relationMap = new Map<String, Set<Id>>(); // key : inspection id, value : user ids to be related 
        for(Inspection__c ins : news) {
            // (target mapping)
            Set<Id> innerSet = new Set<Id>();
            innerSet.add(qmList[0].Id);

            if(orderOwnerMap.containsKey(ins.Order__c) && ins.OwnerId != orderOwnerMap.get(ins.Order__c)) {
                innerSet.add(orderOwnerMap.get(ins.Order__c));
            }

            if(ins.F_OrderType__c == ordSvc.CHANNER_DNSA) {
                if(!dnsaUsers.isEmpty()) { innerSet.addAll(dnsaUsers); }
            } else {
                if(insOwnerMap.containsKey(ins.OwnerId)) { innerSet.add(insOwnerMap.get(ins.OwnerId)); }
            }
            relationMap.put(ins.Id, innerSet);
        }

        return relationMap;
    }
}