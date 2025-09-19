/**
 * @description       : Order Trigger Handler
 * @test              : OrderTriggerHandlerTest
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-07-23
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-18-2024   Hanyeong Choi   Initial Version
**/
public with sharing class OrderTriggerHandler extends TriggerHandler {
    private static final Id recordTypeIdService = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
    public static DN_OrderService ordSvc = new DN_OrderService();

    /**
    * @description 
        Owner__c 필드에 OwnerId 복사
        특정 주문유형(ZPS, ZPSA)에 대해 EffectiveDate를 오늘 날짜로 설정
        RecordType이 'Service'인 경우 Pricebook 설정 및 Quote 기반 Opportunity 연결
        관련된 Quote의 Opportunity 조회 및 매핑
    **/
    public override void onBeforeInsert(List<sObject> news) {
        if (isExecuting) {
            System.debug('Order BEFORE_INSERT TRIGGER Start');
            List<Order> orderList = (List<Order>) news;

            String serviceTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
            Pricebook2 pBook = [SELECT Id, Name FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];

            Set<Id> quoteIds = new Set<Id>();
            for (Order order : orderList) {
                if (order.QuoteId != null) { quoteIds.add(order.QuoteId); }
            }

            Map<Id, Quote> quoteMap = new Map<Id, Quote>();
            if(!quoteIds.isEmpty()) {
                for (Quote q : [SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIds]) {
                    quoteMap.put(q.Id, q);
                }
            }

            for(Order order : orderList){
                order.Owner__c = order.OwnerId; // SLS-ORD-029 

                if(order.OrderType__c == 'ZPS' || order.OrderType__c == 'ZPSA') {
                    order.EffectiveDate = Date.today();
                }

                if (order.RecordTypeId == serviceTypeId) {
                    order.Pricebook2Id = pBook.Id;
                    order.OpportunityId = quoteMap.get(order.QuoteId).OpportunityId;
                }

            }

            preventBlockedAcc(orderList);
            setDefaultValue(orderList);
            setAccountName(orderList);
            setShipToName(orderList, null);
            connetVirtualAccount(orderList, new Set<Id>());
            getShippingCondition(orderList, null);

            setting(false, TriggerOperation.BEFORE_INSERT);
            System.debug('Order BEFORE_INSERT TRIGGER End');
        }
    }

    /**
    * @description 연결된 Account에 대한 처리, 견적 아이템에 대한 처리
    **/
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if (isExecuting) {
            System.debug('Order AFTER_INSERT TRIGGER Start');
            String serviceTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
            Map<Id, String> orderAlertMap = new Map<Id, String>();
            List<Order> orderList = (List<Order>) news;
            Set<Id> orderIds = new Set<Id>();

            for (Order o : orderList) {
                orderIds.add(o.Id);
                orderAlertMap.put(o.Id, o.OrderNumber);
            }

            alertKeyAccount(orderList);
            if (orderList[0].RecordTypeId == serviceTypeId) {
                handleQuoteLineItems(orderList);    // Suheon.Ha
            }

            Set<Id> accountIds = new Set<Id>();
            for(Order o : orderList) {
                if(o.AccountId != null) {
                    accountIds.add(o.AccountId);
                }
            }
            DN_WithoutSharingClass.updateAccountHasOrder(accountIds, 'insert');

            Set<Id> userIds = new Set<Id>();
            userIds.add(UserInfo.getUserId());
            List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);

            // [GSR SR0000010031094] 오더 등록 시 CRM 알람 추가
            if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
                String alertName        = 'Create Order';
                String alertType        = 'Notification';
                String userId           =  UserInfo.getUserId();
                String alertLanguage    = 'ko';
    
                DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,orderAlertMap);
 
                String alertType_email        = 'Email';
                String userId_email           = UserInfo.getUserId();
                String alertLanguage_email    = 'ko';
                String createDate       = String.valueOf(orderList[0].CreatedDate);
                String OrderNumber      = orderList[0].OrderNumber;

                DN_FinalQuoteCheckController.sendEmailAlert(alertType_email,alertName,alertLanguage_email,userId,orderAlertMap,createDate);
            }

            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('Order AFTER_INSERT TRIGGER End');
        }
    }
    
    /**
    * @description 
        Order Owner 변경 시 Owner__c에 업데이트
        Account 변경 여부 및 Vendor 필수 조건을 검사
    **/
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {

        if(isExecuting) {
            System.debug('Order BEFORE_UPDATE TRIGGER Start');
            List<Order> orderList = (List<Order>) news;
            Map<Id, Order> oldOrderMap = (Map<Id, Order>) oldMap;

            preventDataUpdate(orderList, oldOrderMap);
            preventBlockedAcc(orderList);

            Set<Id> accSet = new Set<Id>();
            Set<Id> accChangedIds = new Set<Id>();
            Map<String, Order> quoteMap = new Map<String, Order>();
            List<Order> approvalTarget = new List<Order>();
            for(Order order : orderList) {
                order.Owner__c = order.OwnerId; // SLS-ORD-029

                Order oldOrder = oldOrderMap.get(order.Id);

                if(order.AccountId != oldOrder.AccountId) {
                    accSet.add(order.AccountId);
                    accChangedIds.add(order.AccountId);
                }
                
                if(order.DealerCommission__c != 0 && order.DealerCommission__c != null && order.Vendor__c == null) {
                    order.addError(System.Label.DNS_M_EnterVendor); // Vendor is required. Please provide the vendor details.
                    
                }
            }

            if(!accSet.isEmpty()) { connetVirtualAccount(orderList, accSet); }

            if(!accChangedIds.isEmpty()) { setAccountName(orderList); }
            
            setShipToName(orderList, oldOrderMap);

            if(!quoteMap.isEmpty()) setWarranty(quoteMap);
            changeSoldTo(orderList, oldOrderMap);
            changeAddress(orderList, oldOrderMap);
            syncDealerOrder(orderList, oldOrderMap);
            handleOrderStatus(orderList, oldOrderMap);
            handleOrderCanceled(orderList, oldOrderMap);
            getShippingCondition(orderList, oldOrderMap);
            deletePricing(orderList, oldOrderMap);

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('Order BEFORE_UPDATE TRIGGER End');
        }
    }

    /**
    * @description 주문 승인 알림, Order Product 업데이트, Account에 주문 유무 업데이트
    **/
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        
        if(isExecuting) {
            System.debug('Order AFTER_UPDATE TRIGGER Start');    
            List<Order> orderList       = (List<Order>) news;
            Map<Id, Order> orderOldMap  = (Map<Id, Order>) oldMap;
            Map<Id, Order> orderNewMap  = (Map<Id, Order>) newMap;

            alertOrderConfirmed(orderList, orderOldMap);

            updateItemKey(orderList, orderOldMap, orderNewMap);

            Set<Id> accountIds = new Set<Id>();
            Set<Id> approvalIds = new Set<Id>();
            for(Order o : orderList) {
                if(o.UnderApproval__c) {
                    approvalIds.add(o.Id);
                }

                if(o.AccountId != null) {
                    accountIds.add(o.AccountId);
                }
            }
            if(!approvalIds.isEmpty()) DN_OrderService.sendApprovalNotificationAsync(approvalIds);
            DN_WithoutSharingClass.updateAccountHasOrder(accountIds, 'update');

            setting(false, TriggerOperation.AFTER_UPDATE);
            System.debug('Order AFTER_UPDATE TRIGGER End');
        }
    }

    /**
    * @description 생성 단계 외 주문 삭제 불가
    **/
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
        
        if(isExecuting) {
            System.debug('Order BEFORE_DELETE TRIGGER Start'); 

            List<Order> orderList = (List<Order>) dels;

            Boolean isAdmin = ordSvc.getAdminFlag();
            for(Order order : orderList) {
                if(isAdmin) { continue; }
                else if(order.Status == ordSvc.ORDER_CREATE) { continue; }
                order.addError(System.Label.DNS_M_CannotDeleteOrder); // SLS-ORD-020
            }
            
            setting(false, TriggerOperation.BEFORE_DELETE);
            System.debug('Order BEFORE_DELETE TRIGGER End'); 
        }
    }

    /**
    * @description 연결 된 Account의 주문 유무 업데이트
    **/
    public override void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        
        if(isExecuting) {
            System.debug('Order AFTER_DELETE TRIGGER Start');
            List<Order> orderList = (List<Order>) dels;
            Set<Id> accountIds = new Set<Id>();
            for(Order order : orderList) {
                if(order.AccountId != null) {
                    accountIds.add(order.AccountId);
                }
            }
            DN_WithoutSharingClass.updateAccountHasOrder(accountIds, 'delete');
            setting(false, TriggerOperation.AFTER_DELETE);
            System.debug('Order AFTER_DELETE TRIGGER End');
        }
    }

    /**
    * @description 승인 프로세스 진행 중인 주문 대상으로 알림 발송
    **/
    public static void sendApprovalNotificationAsync(Set<Id> approvalIds) {
        List<Order> target = [SELECT Id, DNSA_SalesOffice__c, OrderNumber, PurchaseOrderNo__c FROM Order WHERE Id IN :approvalIds];
        
        DN_OrderService ordSvc = new DN_OrderService();
        Set<Id> createdUser = new Set<Id>();
        List<ProcessInstance> piList = [
            SELECT Id, TargetObjectId 
            FROM ProcessInstance 
            WHERE TargetObjectId IN :approvalIds
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Map<Id, Id> processInstanceToRecordMap = new Map<Id, Id>();
        if(!piList.isEmpty()) {
            for(ProcessInstance pi : piList) {
                processInstanceToRecordMap.put(pi.Id, pi.TargetObjectId);
            }

            // ProcessInstanceStep 조회
            List<ProcessInstanceStep> steps = [
                SELECT ProcessInstance.TargetObjectId, ActorId, Actor.Name, Comments
                FROM ProcessInstanceStep
                WHERE ProcessInstanceId IN :processInstanceToRecordMap.keySet()
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            // 최신 코멘트 매핑
            Map<Id, String> recordIdToComments = new Map<Id, String>();
            for(ProcessInstanceStep step : steps) {
                Id recordId = processInstanceToRecordMap.get(step.ProcessInstanceId);
                if(recordId != null && !recordIdToComments.containsKey(recordId)) {
                    recordIdToComments.put(recordId, step.Comments != null ? step.Comments : '');
                }
            }

            List<ProcessInstanceWorkitem> workItems = [
                SELECT Id, ProcessInstanceId, OriginalActorId, CreatedById 
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstanceId IN :processInstanceToRecordMap.keySet()
            ];

            Map<String, Object> recordIdToWorkitems = new Map<String, Object>();
            Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();

            if(!workItems.isEmpty()) {
                for(ProcessInstanceWorkitem workItem : workItems) {
                    Id actorId = workItem.OriginalActorId;
                    createdUser.add(workItem.CreatedById);

                    Id recordId = processInstanceToRecordMap.get(workItem.ProcessInstanceId);
                    Set<Id> innerSet = targetUserMap.containsKey(recordId) ? targetUserMap.get(recordId) : new Set<Id>();

                    if(recordId != null) {
                        String key = String.valueOf(recordId);
                        if(!recordIdToWorkitems.containsKey(key)) {
                            recordIdToWorkitems.put(key, new List<ProcessInstanceWorkitem>());
                        }
                        ((List<ProcessInstanceWorkitem>)recordIdToWorkitems.get(key)).add(workItem);
                    }    

                    if (actorId.getSObjectType() == Group.sObjectType) {
                        List<GroupMember> groupMembers = [
                            SELECT UserOrGroupId
                            FROM GroupMember
                            WHERE GroupId = :actorId
                        ];

                        if(!groupMembers.isEmpty()) {
                            for(GroupMember gm : groupMembers) {
                                innerSet.add(gm.UserOrGroupId);
                            }
                        }
                    } else {
                        innerSet.add(actorId);
                    }
                    targetUserMap.put(recordId, innerSet);
                }
            }

            if(!createdUser.isEmpty()) {
                Map<Id, User> createdUserMap = new Map<Id, User>([
                    SELECT Id, Name 
                    FROM User 
                    WHERE Id IN :createdUser
                ]);

                Map<Id, String> userNameMap = new Map<Id, String>();
                for (Id userId : createdUserMap.keySet()) {
                    userNameMap.put(userId, createdUserMap.get(userId).Name);
                }

                Map<Id, String> recordMapForSend = new Map<Id, String>();
                for(String key : recordIdToWorkitems.keySet()){
                    Id recId = (Id) key;
                    List<ProcessInstanceWorkitem> wiList = (List<ProcessInstanceWorkitem>) recordIdToWorkitems.get(key);
                    String value = (wiList != null && !wiList.isEmpty()) ? String.valueOf(wiList[0].Id) : '';
                    recordMapForSend.put(recId, value);
                }

                if(!targetUserMap.isEmpty()){
                    UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                        'CommodityOrderApproved',
                        'email',
                        target,
                        targetUserMap,
                        new Map<String, Object>{
                            'recordIdToWorkitems' => recordMapForSend, 
                            'userNameMap' => userNameMap,
                            'recordIdToComments' => recordIdToComments
                        }
                    );
                    if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { 
                        target[0].addError(emailAlertResult.errMessage); 
                    }
                }
            }
        }
    }


    /**
    * @description 연결 된 Quote 기반 + 조건에 따라 Warranty 설정 및 금액 계산
    **/
    private void setWarranty(Map<String, Order> quoteMap) {
        Id recordTypeIdCommodity  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
        Id recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
        List<Quote> quoteList = [SELECT Id, RecordTypeId FROM Quote WHERE Id IN :quoteMap.keySet()];
        User currentUser = [SELECT Id, AccountId, Account.SalesDistrict__c, SalesDistrict__c FROM User WHERE Id = :UserInfo.getuserId() LIMIT 1];
        List<Order> updateOrderList = new List<Order>();

        if(!quoteList.isEmpty()) {
            for(Quote quote : quoteList) {
                if(quote.RecordTypeId == recordTypeIdCommodity || quote.RecordTypeId == recordTypeIdFactory) {
                    Order order = quoteMap.get(quote.Id);
                    String warranty = order.MachinePartsWarranty__c;
        
                    if(warranty != '') {
                        List<Warranty__c> wrList = new List<Warranty__c>();
                        if(currentUser.AccountId != null) {
                            wrList = [SELECT Id, Percent__c FROM Warranty__c WHERE ZZPR_WAR__c = :warranty AND BZIRK__c = :currentUser.Account.SalesDistrict__c LIMIT 1];
                        } else {
                            wrList = [SELECT Id, Percent__c FROM Warranty__c WHERE ZZPR_WAR__c = :warranty AND BZIRK__c = :currentUser.SalesDistrict__c LIMIT 1];
                        }
        
                        List<OrderItem> oliList = [SELECT StandardPrice__c FROM OrderItem WHERE OrderId = :order.Id AND Accessory__c = null LIMIT 1];
                        if(!wrList.isEmpty() && !oliList.isEmpty()) {
                            if(order.MachinePartsWarranty__c != 'M24') {
                                order.ExtWarranty__c = oliList[0].StandardPrice__c * (wrList[0].Percent__c / 100);
                            } else {
                                order.ExtWarranty__c = 0;
                            }
                            updateOrderList.add(order);
                        }
                    }
                }
            }
        }
        if(!updateOrderList.isEmpty()) update updateOrderList;
        return;
    }



    /**
    * @description virtual account가 있을 경우 주문에 업데이트
    * @author Yuhyun Park  | 07-16-2024
    * @param news 
    * @param accIdSet 
    **/
    private void connetVirtualAccount(List<Order> news, Set<Id> accIdSet){
        Set<Id> accSet = new Set<Id>();

        Map<Id,Id> accParentIdMap = new Map<Id,Id>();
        if(!accIdSet.isEmpty()) { accSet = accIdSet; }
        else {
            for(Order order : news){
                accSet.add(order.AccountId);
            }
        }

        List<Account> accList = [
            SELECT  Id
                    , Name
                    , IsKeyAccount__c
                    , ParentId
            FROM    Account
            WHERE   IsKeyAccount__c = true
            AND     ParentId <> null
            AND     Parent.IsVirtualParent__c = true
            AND     Id IN :accSet
        ];

        for(Account acc : accList){
            accParentIdMap.put(acc.Id, acc.ParentId);
        }

        for(Order order : news){
            if(accParentIdMap.containsKey(order.AccountId)) {
                order.ParentAccount__c = accParentIdMap.get(order.AccountId);
            }
        }
    }

    /**
    * @description owner 변경 시 변경 된 owner가 dealer 라면 dealer의 account와 contact을 order에 업데이트
                   250213 owner가 직영이면 DNS direct account로 Mapping
    * @author yeongju.yun | 2024-10-18 
    * @param news 
    * @param oldMap 
    **/
    private void syncDealerOrder(List<Order> news, Map<Id, Order> oldMap){

        Set<Id> ownerIdSet        = new Set<Id>();
        List<Order> targetList    = new List<Order>();

        List<Order> segTargetList = new List<Order>();
        for(Order order : news) {
            if(oldMap.get(order.Id).OwnerId != order.OwnerId) {
                ownerIdSet.add(order.OwnerId);
                targetList.add(order);
            } 
        }

        if(!ownerIdSet.isEmpty()) {
            // user setting
            List<User> userList   = [
                SELECT  Id, Name, AccountId, ContactId, UserType, SalesOffice__c, SalesOrganization__c, Profile.Name
                FROM    User 
                WHERE   Id =:ownerIdSet
            ];
            
            Map<Id, User> userMap = new Map<Id, User>(userList);
            Set<String> officeSet = new Set<String>();
            Set<String> orgSet = new Set<String>();
            for(User u : userList) {
                officeSet.add(u.SalesOffice__c);
                orgSet.add(u.SalesOrganization__c);
            }

            // dns direct account setting
            List<Account> accList = [
                SELECT  Id, SalesOffice__c, SalesOrganization__c
                FROM    Account 
                WHERE   IsDNSDirectAccount__c = true
                AND     SalesOffice__c = : officeSet
                AND     SalesOrganization__c =: orgSet
            ];
            Map<String, Id> accMap = new Map<String, Id>(); // key : SalesOffice__c + _ +  SalesOrganization__c, value : account id
            for(Account acc : accList) {
                accMap.put(acc.SalesOffice__c + '_' + acc.SalesOrganization__c, acc.Id);
            }

            for(Order order : targetList) {
                User u = userMap.get(order.OwnerId);
                if(ordSvc.ADMINS.contains(u.Profile.Name)) continue;
                
                if(u.UserType == 'Standard') { // direct sales
                    String orderKey = order.SalesOffice__c + '_' + order.SalesOrganization__c;
                    if(accMap.containsKey(orderKey)) {
                        order.SalesRep__c      = accMap.get(orderKey); // DNS direct account
                        order.CreditDealer__c  = accMap.get(orderKey); // DNS direct account
                        order.ServiceDealer__c = accMap.get(orderKey); // DNS direct account
                        order.RelatedDealer__c = accMap.get(orderKey); // DNS direct account
                        order.DealerContact__c = null; // no contact info width DNS direct account
                    } else {
                        if(!Test.isRunningTest()) order.addError(System.Label.DNS_M_NoDirectAcc); // There is no DNS direct account.
                    }
                } else { // dealer
                    order.SalesRep__c      = userMap.get(order.OwnerId).AccountId; // dealer's account
                    order.CreditDealer__c  = userMap.get(order.OwnerId).AccountId; // dealer's account
                    order.ServiceDealer__c = userMap.get(order.OwnerId).AccountId; // dealer's account
                    order.RelatedDealer__c = userMap.get(order.OwnerId).AccountId; // dealer's account
                    order.DealerContact__c = userMap.get(order.OwnerId).ContactId; // dealer(contact)
                }
            }
        }
    }

    /**
    * @description order의 account가 key account라면 KA팀에게 notificiation
    * @author yeongju.yun | 2024-10-22 
    * @param news 
    **/
    private void alertKeyAccount(List<Order> news) {
        Set<Id> accIdSet = new Set<Id>();
        for(Order order : news) {
            accIdSet.add(order.AccountId);
        }
        List<Account> accList  = [ SELECT Id, Name, IsKeyAccount__c FROM Account WHERE Id =: accIdSet ];

        Map<Id, String> accNameMap = new Map<Id, String>();
        Map<Id, Boolean> accKeyMap = new Map<Id, Boolean>();
        for(Account acc : accList) {
            accNameMap.put(acc.Id, acc.Name);
            accKeyMap.put(acc.Id, acc.IsKeyAccount__c);
        }

        List<User> userList = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND Profile.Name = :ordSvc.KA];
        Set<Id> targetUser = new Set<Id>();
        for(User u : userList) {
            targetUser.add(u.Id);
        }

        List<Order> target = new List<Order>();
        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        for(Order order : news) {
            if(accKeyMap.get(order.AccountId)) { 
                target.add(order); 
                targetUserMap.put(order.Id, targetUser);
            }
        }

        if(!target.isEmpty()) {
            if(targetUserMap.isEmpty()) {
                news[0].addError(SYstem.Label.DNS_M_NoKATeam);
                // There is no KA Team. Please Contact the administrator.
            }

            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'OrderKeyAccountCreated'
                , 'bell'
                , target
                , targetUserMap
                , new Map<String, Object>{'accNameMap' => accNameMap}
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(bellAlertResult.errMessage); }

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'OrderKeyAccountCreated'
                , 'email'
                , target
                , targetUserMap
                , new Map<String, Object>{'accNameMap' => accNameMap}
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){ target[0].addError(emailAlertResult.errMessage); }
        }
    }

    /**
    * @description order의 status가 'confirmed'가 되었을 때 Owner가 Dealer일 경우 noti
                   20250313 Owner가 Dealer가 아니어도 noti
    * @author yeongju.yun | 2024-10-22 
    * @param news 
    * @param oldMap 
    **/
    private void alertOrderConfirmed(List<Order> news, Map<Id, Order> oldMap) {
        Set<Id> userIds = new Set<Id>();
        for(Order order : news){
            userIds.add(order.OwnerId);
        }

        List<Order> target  = new List<Order>();
        Set<Id> targetUser  = new Set<Id>();
        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        for(Order order : news) {

            if(oldMap.get(order.Id).Status != ordSvc.ORDER_CONFIRMED && order.Status == ordSvc.ORDER_CONFIRMED) {
                
                target.add(order);
                targetUser.add(order.OwnerId);
                targetUserMap.put(order.Id, new Set<Id>{order.OwnerId});
            }
        }

        if(!target.isEmpty()) {

            Map<Id, String> userNameMap = ordSvc.getUserNameMap(targetUser);

            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'OrderStatusConfirmed'
                , 'bell'
                , target
                , targetUserMap
                , new Map<String, Object>{'userNameMap' => userNameMap}
            );

            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(bellAlertResult.errMessage); }

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'OrderStatusConfirmed'
                , 'email'
                , target
                , targetUserMap
                , new Map<String, Object>{'userNameMap' => userNameMap}
            );

            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(emailAlertResult.errMessage); }
        }
    }

    /**
    * @description [SLS-ORD-003] IsAccountBlocked__c = true > prevent to insert/upsert order
    * @author yeongju.yun | 2024-10-25 
    * @param news 
    **/
    private void preventBlockedAcc(List<Order> news){

        Set<Id> accIdSet = new Set<Id>();
        List<Order> target = new List<Order>();
        for(Order order : news) {
            if(order.IsAccountBlocked__c == null) { // insert
                target.add(order);
                accIdSet.add(order.AccountId);
            } else if(order.IsAccountBlocked__c) { // update
                order.addError(System.Label.DNS_M_OrderAccountBlocked);
                // The associated Account is blocked, so the order cannot be created or modified.
            }
        }

        List<Account> accList = [SELECT Id, IsBlocked__c FROM Account WHERE IsBlocked__c = TRUE AND Id =: accIdSet];
        Set<Id> blockedAccSet = new Set<Id>();
        for(Account acc : accList) {
            if(acc.IsBlocked__c) { blockedAccSet.add(acc.Id); }
        }

        if(!blockedAccSet.isEmpty()) {
            for(Order order : target) {
                if(blockedAccSet.contains(order.AccountId)) {
                    order.addError(System.Label.DNS_M_OrderAccountBlocked);
                }
            }
        }
    }

    /**
    * @description Order의 ShipTo__c, SoldTo__c가 변경 되면 ShippingAddress, SoldToAddress(=BillingAddress) Sync.
    * @author yeongju.yun | 2024-10-25 
    * @param news 
    * @param oldMap 
    **/
    private void changeAddress(List<Order> news, Map<Id, Order> oldMap) {

        List<Order> soldToChanged = new List<Order>();
        List<Order> shipToChanged = new List<Order>();

        Set<Id> accIdSet = new Set<Id>();
        for(Order order : news) {
            if(order.SoldTo__c != oldMap.get(order.Id).SoldTo__c) {
                accIdSet.add(order.SoldTo__c);
                soldToChanged.add(order);
            }

            if(order.ShipTo__c != oldMap.get(order.Id).ShipTo__c) {
                accIdSet.add(order.ShipTo__c);
                shipToChanged.add(order);
            }
        }

        if(accIdSet.isEmpty()) return;
        
        List<Account> accList = [SELECT Id, ShippingState, ShippingCity, ShippingStreet, ShippingPostalCode, ShippingCountry FROM Account WHERE Id =: accIdSet];
        Map<Id, Account> accMap = new Map<Id, Account>(accList);

        if(!soldToChanged.isEmpty()) {
            for(Order order : soldToChanged) {
                if(!accMap.containsKey(order.SoldTo__c)) continue;
                Account acc = accMap.get(order.SoldTo__c);
                order.BillingState      = acc.ShippingState;
                order.BillingCity       = acc.ShippingCity;
                order.BillingStreet     = acc.ShippingStreet;
                order.BillingPostalCode = acc.ShippingPostalCode;
                order.BillingCountry    = acc.ShippingCountry;
            }
        }
        if(!shipToChanged.isEmpty()) {
            for(Order order : shipToChanged) {
                if(!accMap.containsKey(order.ShipTo__c)) continue;
                Account acc = accMap.get(order.ShipTo__c);
                
                order.ShippingState      = acc.ShippingState;
                order.ShippingCity       = acc.ShippingCity;
                order.ShippingStreet     = acc.ShippingStreet;
                order.ShippingPostalCode = acc.ShippingPostalCode;
                order.ShippingCountry    = acc.ShippingCountry;
            }
        }
    }

    /**
    * @description 'Created'일 때는 모두 수정 가능, 'Internal Approved'일 때는 Dealer(Worker) 제외 수정 가능,
                   'Confirmation in Progress' 부터는 CRM에서 User가 Order 수정 불가
                   Mapping할 수 있는 Asset이 없을 때 Status변경 없이 Record Lock
                   250213 user의 타입에 따라 order segmentation값 제한
                   250402 DNSA Order의 타입에 따라 특정 필드 수정 불가
                   250403 DNSA Option Only 타입은 특정 필드 추가로 수정 불가
    * @author yeongju.yun | 2024-10-28 
    * @param news 
    **/
    private void preventDataUpdate(List<Order> news, Map<Id, Order> oldMap){
        List<Profile> profileList = [SELECT Id FROM Profile WHERE Name =: ordSvc.ADMINS];
        
        Set<Id> adminProfileSet = new Set<Id>();
        for(Profile p : profileList) {
            adminProfileSet.add(p.Id);
        }

        Set<Id> orderOwnerIdSet = new Set<Id>();
        for(Order order : news) {
            orderOwnerIdSet.add(order.OwnerId);
        }
        orderOwnerIdSet.add(UserInfo.getUserId());
        Map<Id, Boolean> managerMap = ordSvc.isManager(orderOwnerIdSet);

        Id recordTypeDNSA = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
        List<String> dnsaNoUpdateFields = new List<String>{
            'PUBldgConstruction__c', 'PUNewFoundation__c', 'PUAccessoryDelivery__c', 'PUFinancialApproval__c'
            , 'PUContractApproval__c', 'PUExportLicense__c', 'Other__c'
        };

        List<String> dnsaOptionNoUp = new List<String>{'PaymentTerms__c', 'PaymentTerms_DNSA__c', 'Incoterms__c', 'FOBPoint__c', 'MachinePartsWarranty__c'};

        Map<String,Schema.SObjectField> fieldMap = Schema.Order.SObjectType.getDescribe().fields.getMap();
        
        for(Order order : news) {
            Order oldOrder = oldMap.get(order.Id);
            if(
                (adminProfileSet.contains(UserInfo.getProfileId()))
                || (order.IF_FreePass__c)
                || (order.IsOrderDeleted__c && !oldOrder.IsOrderDeleted__c)
                || (String.isBlank(oldOrder.ERPOrderNo__c) &&  String.isNotBlank(order.ERPOrderNo__c))
                || (order.RecordTypeId == recordTypeIdService)
                || (order.UnderApproval__c && !oldOrder.UnderApproval__c)
            ) { 
                order.IF_FreePass__c = false;
                continue;
            } 

            // if(oldOrder.Status == ordSvc.ORDER_APPROVED && (!managerMap.get(UserInfo.getUserId()) && !ordSvc.IS_USER)) {
            if(oldOrder.Status == order.Status && order.Status != ordSvc.ORDER_CREATE && (!managerMap.get(UserInfo.getUserId()) && !ordSvc.IS_USER)) {
                order.addError(System.Label.DNS_M_NotAllowedUpdateOrder); // Updates are only allowed in the 'Order Create' status.
            } else if(String.isNotBlank(oldOrder.ERPOrderNo__c) && String.isNotBlank(order.ERPOrderNo__c)) {
                order.addError(System.Label.DNS_M_OrderSentERP); // Orders transmitted to the ERP cannot be modified.
            } else if(String.isNotBlank(oldOrder.ERPRSONo__c) && String.isNotBlank(order.ERPRSONo__c)) {
                order.addError(System.Label.DNS_M_OrderSentERP); // Orders transmitted to the ERP cannot be modified.
            } else if(oldOrder.OrderSegmentation__c != order.OrderSegmentation__c && order.OrderSegmentation__c == ordSvc.SEG_DIRECTSALES && !ordSvc.IS_USER) {
                order.addError(System.Label.DN_M_OrderSegNoDirectSales); // Only DN employees can select 'Direct Sales'.
            } else if(oldOrder.OrderSegmentation__c != order.OrderSegmentation__c && order.OrderSegmentation__c != ordSvc.SEG_DIRECTSALES && ordSvc.IS_USER) {
                order.addError(System.Label.DN_M_OrderSegNoDirectSales);
            } else if(order.Status != 'Created' && order.RecordTypeId == recordTypeDNSA && order.Status == oldOrder.Status) {
                order.addError('Orders can only be edited when they are in Created Status.');
            }


            else if(order.RecordTypeId == recordTypeDNSA && (order.OrderType__c == 'ZUSO' || order.FM_QuoteRecordType__c == 'DNSA_Factory')) {
                for(String field : dnsaNoUpdateFields) {
                    if(order.get(field) != oldOrder.get(field)) {
                        Schema.DescribeFieldResult fieldResult = fieldMap.get(field).getDescribe();
                        order.addError('This field cannot be edited. : ' + fieldResult.getLabel());
                    }
                }

                if(order.OrderType__c == 'ZUSO') {
                    for(String field : dnsaOptionNoUp) {
                        if(order.get(field) != oldOrder.get(field)) {
                            Schema.DescribeFieldResult fieldResult = fieldMap.get(field).getDescribe();
                            order.addError('This field cannot be edited. : ' + fieldResult.getLabel());
                        }
                    }
                }
            }
        }
    }

    /**
    * @description Order Status
        - [SLS-ORD-014] ConfirmationInProgress > Confirmed
        - [SLS-ORD-015] Confirmed > OrderMapped
                        PSO값을 기반으로 SO Serial Number(Asset)을 맵핑
                        단, Mapping할 수 있는 Asset이 없을 때 Status변경 없이 Record Lock
        - 20250423 ZPSA일 경우 Confirm만 되면 2번대 오더 번호 없어도 Mapped단계로 변경경
    * @author yeongju.yun | 2024-10-28 
    * @param news 
    * @param oldMap 
    **/
    private void handleOrderStatus(List<Order> news, Map<Id, Order> oldMap) {

        // status
        List<Schema.PicklistEntry> picklistEntries = Order.Status.getDescribe().getPicklistValues();
        List<String> statusList = new List<String>();
        for (Schema.PicklistEntry entry : picklistEntries) {
            statusList.add(entry.getValue());
        }

        Set<String> serialNoSet  = new Set<String>();
        List<Order> serialOrderList = new List<Order>();
        
        List<Order> confirmedOrder = new List<Order>();
        Set<String> confirmedIds = new Set<String>();
        for(Order order : news) {

            Boolean isDNSA = order.SalesChannelType__c == ordSvc.CHANNER_DNSA;
            String status_Save = order.Status;

            if(String.isBlank(oldMap.get(order.Id).ERPPSONo__c) && String.isNotBlank(order.ERPPSONo__c)) {
                order.OrderMappedDate__c = Date.today();
                if(order.OrderConfirmedDate__c == null ) { order.OrderConfirmedDate__c = Date.today(); }
                if(!isDNSA) order.Status = ordSvc.ORDER_MAPPED;
            } else if(!oldMap.get(order.Id).IF_IsERPConfirmed__c && order.IF_IsERPConfirmed__c) {
                order.OrderConfirmedDate__c = Date.today();
                order.Status = isDNSA ? ordSvc.ORDER_CONFIRMED_DNSA : ordSvc.ORDER_CONFIRMED;
                order.ApprovalStatus__c = ordSvc.APPROVAL_COMPLATED;
                confirmedOrder.add(order);
                confirmedIds.add(order.Id);
                if(order.OrderType__c == 'ZPSA') {
                    order.OrderMappedDate__c = Date.today();
                    order.Status = ordSvc.ORDER_MAPPED;
                }
            }

            // rollback
            String status_Change = order.Status;
            Integer saveIndex    = statusList.indexOf(status_Save);
            Integer changeIndex  = statusList.indexOf(status_Change);
            if(saveIndex > -1 && changeIndex > -1 && changeIndex < saveIndex) {
                order.Status = status_Save;
            }

            if(oldMap.get(order.Id).SerialNumber__c != order.SerialNumber__c) {
                if(String.isNotBlank(order.SerialNumber__c)) serialNoSet.add(order.SerialNumber__c);
                serialOrderList.add(order);
            }
        }

        if(!confirmedOrder.isEmpty()) {

            List<OrderApproval__c> appvs = [
                SELECT  Id, DecisionDate__c, Status__c
                FROM    OrderApproval__c 
                WHERE   Order__c =:confirmedIds 
                AND     StepName__c =: ordSvc.STEPNAME_ERP
                AND     Status__c =: ordSvc.APPROVALSTATUS_PENDING
            ];

            for(OrderApproval__c appv : appvs) {
                appv.DecisionDate__c = Date.today();
                appv.Status__c       = ordSvc.APPROVALSTATUS_APPROVED;
            }

            if(!appvs.isEmpty()) { update appvs; }
        }

        if(!serialOrderList.isEmpty()) {
            
            List<Asset> equipmentList = new List<Asset>();
            if(!serialNoSet.isEmpty()) {
                equipmentList = [SELECT Id, Name, SerialNumber FROM Asset WHERE Name =: serialNoSet ];
            }

            Map<String, Id> serialNoMap = new Map<String, Id>(); // key : serial number, value : equipment id
            for(Asset equipment : equipmentList) {
                serialNoMap.put(equipment.Name, equipment.Id);
            }

            for(Order order : serialOrderList) {
                if(serialNoMap.containsKey(order.SerialNumber__c)) {
                    order.SOSerialNumber__c = serialNoMap.get(order.SerialNumber__c);
                } else {
                    order.SOSerialNumber__c = null;
                }
            }
        }
    }

    /**
    * @description 
    - Order Cancel로 Status변경 : CancelReason__c, IsOrderDeleted__c
    - Order Returned로 Status 변경 : ReturnOrderNumber__c
    - 연결된 Quote Product는 다시 Order 생성 할 수 있도록 변경
    - 취소 시 딜러에게 취소 Notification
    * @author yeongju.yun | 2024-10-30 
    * @param news 
    * @param oldMap 
    **/
    private void handleOrderCanceled(List<Order> news, Map<Id, Order> oldMap) {

        List<Order> notiTarget = new List<Order>();
        Set<Id>     notiUsers  = new Set<Id>();
        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();

        Set<Id> userIds = new Set<Id>();
        for(Order order : news){
            userIds.add(order.OwnerId);

            if(order.IsOrderDeleted__c && !oldMap.get(order.Id).IsOrderDeleted__c && String.isBlank(order.CancelReason__c)) {
                order.CancelReason__c = 'Y0'; // Sales Order deleted
            }
        }
        Map<Id, Boolean> userTypeMap = ordSvc.getUserFlag(userIds);

        Set<Id> prodTarget = new Set<Id>();
        for(Order order : news) {

            // Return
            if(String.isNotBlank(order.ReturnOrderNumber__c) && String.isBlank(oldMap.get(order.Id).ReturnOrderNumber__c)) {
                order.Status = ordSvc.ORDER_Returned;
            }
            // Cancel
            else if(String.isNotBlank(order.CancelReason__c) && String.isBlank(oldMap.get(order.Id).CancelReason__c)) {
                order.Status = ordSvc.ORDER_CANCELED;

                if(order.CancelReason__c != 'SM') { prodTarget.add(order.Id); }
                if(!userTypeMap.get(order.OwnerId)) { 
                    notiTarget.add(order); 
                    notiUsers.add(order.OwnerId);
                    targetUserMap.put(order.Id, new Set<Id>{order.OwnerId});
                }
            } 
        }

        // [SLS-ORD-020] 연결된 Quote Product는 다시 Order 생성 할 수 있도록 변경
        List<QuoteLineItem> itemList = [SELECT Id, Order__c FROM QuoteLineItem WHERE Order__c =: prodTarget];
        for(QuoteLineItem item : itemList) {
            item.Order__c = null;
        }
        if(!itemList.isEmpty()) { update itemList; }

        // [SLS-ORD-020, SLS-ORD-045] 주문 취소 시 딜러에게 취소 Notification
        if(!notiTarget.isEmpty()) {
            Map<Id, String>  userNameMap = ordSvc.getUserNameMap(notiUsers);

            Map<String, String> reasonMap = ordSvc.getPicklistMap('Order', 'CancelReason__c');
            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'OrderCanceled'
                , 'bell'
                , notiTarget
                , targetUserMap
                , new Map<String, Object>{'userNameMap' => userNameMap, 'reasonMap'=> reasonMap}
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { notiTarget[0].addError(bellAlertResult.errMessage); }

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'OrderCanceled'
                , 'email'
                , notiTarget
                , targetUserMap
                , new Map<String, Object>{'userNameMap' => userNameMap, 'reasonMap'=> reasonMap}
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { notiTarget[0].addError(emailAlertResult.errMessage); }
        }
    }

    /**
    * @description Sold To의 Sales Area Data 중 Order Owner의 SalesOrganization__c, Division__c, DistributionChannel__c가 일치하는 레코드의 Shipping condition 가져옴
    * @author yeongju.yun | 2024-12-31 
    * @param news 
    **/
    private void getShippingCondition(List<Order> news, Map<Id, Order> oldMap) {
        Boolean isUpdate    = oldMap != null;

        Set<Id> soldToIdSet     = new Set<Id>();
        Set<String> orgSet      = new Set<String>();
        Set<String> dChennalSet = new Set<String>();
        Set<String> divisionSet = new Set<String>();

        List<Order> dnsTarget  = new List<Order>();
        for(Order order : news) {
            
            if(order.SalesChannelType__c == ordSvc.CHANNER_DNSA && order.OrderType__c == 'ZDOB') {
                order.ShippingConditions__c = '10';
            } else if(order.SalesChannelType__c == ordSvc.CHANNER_DNSA && order.OrderType__c == 'ZEXB') {
                order.ShippingConditions__c = '11';
            } else if((isUpdate && order.SoldTo__c != oldMap.get(order.Id).SoldTo__c) || !isUpdate) {
                soldToIdSet.add(order.SoldTo__c);
                orgSet.adD(order.SalesOrganization__c);
                dChennalSet.adD(order.DistributionChannel__c);
                divisionSet.adD(order.Division__c);
                dnsTarget.add(order);
            } 
        }

        if(!dnsTarget.isEmpty()) {
            List<SalesAreaData__c> dataList = [
                SELECT  Id, ShippingConditions__c, Account__c, SalesOrganization__c, DistributionChannel__c, Division__c
                FROM    SalesAreaData__c
                WHERE   Account__c =: soldToIdSet
                AND     SalesOrganization__c =: orgSet
                AND     DistributionChannel__c =: dChennalSet
                AND     Division__c =: divisionSet
            ];

            Map<String, String> shipCndMap = new Map<String, String>(); // key : acc + s org. + d chennel + division, value : ShippingConditions__c
            for(SalesAreaData__c data : dataList) {
                String key = data.Account__c + data.SalesOrganization__c + data.DistributionChannel__c + data.Division__c;
                shipCndMap.put(key, data.ShippingConditions__c);
            }

            if(!shipCndMap.isEmpty()) {
                for(Order order : dnsTarget) {
                    String key = order.SoldTo__c + order.SalesOrganization__c + order.DistributionChannel__c + order.Division__c;
                    if(shipCndMap.containsKey(key)) {
                        order.ShippingConditions__c = shipCndMap.get(key);
                    }
                }
            }
        }
    }

    /**
    * @description Order의 ERPOrderNo__c가 생기면 Order Item의 Key값 셋팅
    * @author yeongju.yun | 2025-01-02 
    * @param news 
    * @param oldMap 
    * @param newMap 
    **/
    private void updateItemKey(List<Order> news, Map<Id, Order> oldMap, Map<Id, Order> newMap) {

        Set<Id> orderIdSet = new Set<Id>();
        for(Order order : news) {
            if(String.isBlank(oldMap.get(order.Id).ERPOrderNo__c) && String.isNotBlank(order.ERPOrderNo__c)) {
                orderIdSet.add(order.Id);
            }
        }

        if(!orderIdSet.isEmpty()) {
            List<OrderItem> itemList = [SELECT Id, OrderId, Key__c, IF_POSNR__c FROM OrderItem WHERE OrderId =: orderIdSet];
            for(OrderItem item : itemList) {
                item.Key__c = newMap.get(item.OrderId).ERPOrderNo__c + '_' + item.IF_POSNR__c;
                item.IF_FreePass__c = true;
            }
            update itemList;
        }
    }

    /**
    * @description Key Fields(OrderSegmentation__c, PaymentTerms__c) 변경 시 가격 정보 다시 받아오도록 하고, 기존 선택된 것이 있다면 삭제
                   Payment Schedule에 기존에 Draft No 등록된 것이 있다면 reset
                   20250512 ERP전송 후에는 삭제 금지
    * @author yeongju.yun | 2025-01-06 
    * @param news 
    * @param oldMap 
    **/
    private void deletePricing(List<Order> news, Map<Id, Order> oldMap) {

        Set<Id> targetIdSet = new Set<Id>();
        for(Order order : news) {
            if(String.isNotBlank(order.ERPOrderNo__c)) continue; // 20250512 ERP전송 후에는 삭제 금지

            if(oldMap.get(order.Id).OrderSegmentation__c != order.OrderSegmentation__c || oldMap.get(order.Id).PaymentTerms__c != order.PaymentTerms__c) {
                order.IsSyncPrice__c          = false;
                order.HasScheduleCompleted__c = false;
                order.DCAmount__c             = 0;
                targetIdSet.add(order.Id);
            }
        }

        if(!targetIdSet.isEmpty()) {

            List<OrderPricingSelected__c> selectedList = [SELECT Id FROM OrderPricingSelected__c WHERE Order__c =: targetIdSet];
            if(!selectedList.isEmpty()) { delete selectedList; }
    
            List<PaymentSchedule__c> paymentSchedules = [SELECT Id, DraftCheck__c, DraftNo__c, DraftNoText__c FROM PaymentSchedule__c WHERE Order__c =: targetIdSet];
            List<PaymentSchedule__c> toUpdatePayment = new List<PaymentSchedule__c>();
            for(PaymentSchedule__c paymentSchedule : paymentSchedules) {
                paymentSchedule.DraftCheck__c      = 'NotRequested';
                paymentSchedule.DraftNo__c         = null;
                paymentSchedule.DraftNoText__c     = null;
                toUpdatePayment.add(paymentSchedule);
            }
            if(!toUpdatePayment.isEmpty()) { update toUpdatePayment;}
        }

    }

    /**
    * @description OrderSegmentation__c변경 시 Sold To Account 변경
    * @author yeongju.yun | 2025-01-07
    * @param news 
    * @param oldMap 
    **/
    private void changeSoldTo(List<Order> news, Map<Id, Order> oldMap){
        Id recordTypeDNS = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNS').getRecordTypeId();

        Set<Id> dealerIds = new Set<Id>();
        for(Order order : news) {
            dealerIds.add(order.OwnerId);
        }

        List<User> dealerInfos = [SELECT Id, Name, AccountId FROM User WHERE AccountId <> null AND Id =: dealerIds];
        Map<Id, Id> dealerInfoMap = new Map<Id, Id>(); // key : order owner id, value : dealer account id
        if(!dealerInfos.isEmpty()) {
            for(User u : dealerInfos) {
                if(u.AccountId != null) { dealerInfoMap.put(u.Id, u.AccountId); }
            }
        }

        for(Order order : news) {
            if(order.OrderSegmentation__c != oldMap.get(order.Id).OrderSegmentation__c 
                && ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c)
                && order.RecordTypeId == recordTypeDNS
            ) {
                if(order.OrderSegmentation__c == ordSvc.SEG_CONSIGNMENT) {
                    order.SoldTo__c = order.AccountId;
                } else if(order.OrderSegmentation__c == ordSvc.SEG_WHOLESALE && dealerInfoMap.containsKey(order.OwnerId)) {
                    order.SoldTo__c = dealerInfoMap.get(order.OwnerId);
                }
            }
        }
    }

    /**
     * @description
        - QuoteLineItem 처리 및 OrderItem 생성
        - QuoteLineItem -> OrderItem Suheon.Ha 2025-01-13 
     */
    private void handleQuoteLineItems(List<Order> orders) {
        List<PricebookEntry> pbeList = [
            SELECT Id, Product2.ProductCode, Product2Id
            FROM PricebookEntry 
            WHERE Product2.ProductCode IN ('CS_MT_MAT', 'CS_MT_SVC')
        ];
    
        Map<String, PricebookEntry> pbeMap = new Map<String, PricebookEntry>();
        for (PricebookEntry pbe : pbeList) {
            pbeMap.put(pbe.Product2.ProductCode, pbe);
        }
    
        Map<Id, List<QuoteLineItem>> qliMap = getQuoteLineItems(orders);
        List<OrderItem> oiList = new List<OrderItem>();
    
        String recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
    
        for (Order order : orders) {
            // RecordType이 Service인 경우에만 처리
            if (order.RecordTypeId == recordTypeId) {
                List<QuoteLineItem> qliList = qliMap.get(order.QuoteId);
    
                // Decimal csMtMatTotal = 0;
                Decimal csMtSvcTotal = 0;

                if (qliList != null && !qliList.isEmpty()) {
                    for (QuoteLineItem qli : qliList) {
                        String productCode = qli.Product2.ProductCode;
                
                        if (productCode == 'CS_MT_SVC') {
                            csMtSvcTotal += qli.TotalPrice;
                        } else {
                            oiList.add(createGeneralQuoteLineItem(qli, order.Id));
                        }
                    }
                }
                
                // CS_MT_SVC OrderItem 생성 (수량 1로 고정)
                if (csMtSvcTotal > 0 && pbeMap.containsKey('CS_MT_SVC')) {
                    oiList.add(createCustomOrderItem(order.Id, 'CS_MT_SVC', csMtSvcTotal, pbeMap.get('CS_MT_SVC')));
                }
                
            }
        }
    
        if (!oiList.isEmpty()) {
            insert oiList;
            System.debug('Inserted OrderItems: ' + oiList.size());
        } else {
            System.debug('No OrderItems to insert');
        }
    }

    /**
     * @description
        - QuoteLineItem 데이터를 Order와 매핑하여 반환
     */
    private Map<Id, List<QuoteLineItem>> getQuoteLineItems(List<Order> orders) {
        Set<Id> quoteIds = new Set<Id>();
        for (Order order : orders) {
            if (order.QuoteId != null) {
                quoteIds.add(order.QuoteId);
            }
        }
    
        Map<Id, List<QuoteLineItem>> qliMap = new Map<Id, List<QuoteLineItem>>();
        if (!quoteIds.isEmpty()) {
            List<QuoteLineItem> quoteLineItems = [
                SELECT Id, QuoteId, Product2.ProductCode, TotalPrice, Quantity, UnitPrice, PricebookEntryId, Product2Id, CSTotalPrice__c
                FROM QuoteLineItem
                WHERE QuoteId IN :quoteIds
            ];
            for (QuoteLineItem qli : quoteLineItems) {
                List<QuoteLineItem> valueList = new List<QuoteLineItem>();
                if (qliMap.containsKey(qli.QuoteId)) {
                    valueList = qliMap.get(qli.QuoteId);
                }
                valueList.add(qli);
                qliMap.put(qli.QuoteId, valueList);
            }
        }
        return qliMap;
    }
    
    /**
     * @description
        - 개별 QuoteLineItem을 OrderItem으로 변환
     */
    private OrderItem createGeneralQuoteLineItem(QuoteLineItem qli, Id orderId) {
        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = orderId;
        orderItem.Product2Id = qli.Product2Id;
        orderItem.PricebookEntryId = qli.PricebookEntryId;
        orderItem.Quantity = qli.Quantity;
        orderItem.UnitPrice = qli.UnitPrice;
        orderItem.CSTotalPrice__c = qli.CSTotalPrice__c;
        return orderItem;
    }
    
    /**
     * @description
        - 특정 조건(OrderId, ProductCode, TotalPrice) 기반 OrderItem 생성
     */
    private OrderItem createCustomOrderItem(Id orderId, String productCode, Decimal totalPrice, PricebookEntry pbe) {
        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = orderId;
        orderItem.Product2Id = pbe.Product2Id;
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Quantity = 1;
        orderItem.UnitPrice = totalPrice;
        orderItem.CSTotalPrice__c = totalPrice;
        return orderItem;
    }
    
    /**
    * @description SalesChannelType__c, Country__c, DNSA_SalesOffice__c
                    20250330 Owner의 SalesDistrict__c, SoldTo의 DistributionChannel__c를 order에 업데이트
    * @author yeongju.yun | 2025-01-13 
    * @param news 
    **/
    private void setDefaultValue(List<Order> news){

        Id servicRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ordSvc.ORDER_TYPE_SERVICE).getRecordTypeId();
        Id dnsaRecordTypeId   = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ordSvc.ORDER_TYPE_DNSA).getRecordTypeId();

        Set<Id> optyIds = new Set<Id>();
        Set<Id> soldToIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<Order> target = new List<Order>();
        List<DN_OrderService.ChannerWrapper> cWrapList = new List<DN_OrderService.ChannerWrapper>();
        for(Order order : news) {
            if(order.RecordTypeId == null || order.RecordTypeId == servicRecordTypeId) continue;

            if(order.OrderType__c == 'ZUSO') { // DNSA Option only order
                order.DNSA_SalesOffice__c = '414A';
            } 

            optyIds.add(order.OpportunityId);
            soldToIds.add(order.SoldTo__c);
            userIds.add(order.OwnerId);
            target.add(order);
            
            String accIdStr = order.SoldTo__c == null ? order.AccountId : order.SoldTo__c;
            DN_OrderService.ChannerWrapper cWrap = new DN_OrderService.ChannerWrapper(order.OwnerId, order.RecordTypeId == dnsaRecordTypeId);
            cWrapList.add(cWrap);
        }

        if(!target.isEmpty()) {
            Map<Id, String> optyMap = new Map<Id, String>();
            List<Opportunity> optyList = [SELECT Id, Country__c FROM Opportunity WHERE Id =: optyIds];
            for(Opportunity opty : optyList) {
                String country = opty.Country__c == null ? 'None' : opty.Country__c;
                optyMap.put(opty.Id, country);
            }

            List<User> uList = [SELECT Id, SalesDistrict__c, Profile.Name FROM User WHERE Id = :userIds];
            Map<Id, String> userDisMap = new Map<Id, String>();
            Map<Id, Boolean> adminFlag = new Map<Id, Boolean>();
            for(User u : uList) {
                userDisMap.put(u.Id, u.SalesDistrict__c);
                adminFlag.put(u.Id, ordSvc.ADMINS.contains(u.Profile.Name));
            }

            Map<Id, String> salesChannelTypes = ordSvc.setSalesChannel(cWrapList);

            for(Order order : news) {

                order.SalesDistrict__c = userDisMap.get(order.OwnerId);

                if(adminFlag.get(order.OwnerId)) continue; // pass admin
                
                order.SalesChannelType__c = salesChannelTypes.get(order.OwnerId);

                if(order.SalesChannelType__c != ordSvc.CHANNER_DNSA) {
                    order.DistributionChannel__c = order.SalesChannelType__c == ordSvc.CHANNER_OVERSEAS ? '20' : '10';
                }

                if(order.SalesChannelType__c != ordSvc.CHANNER_DNSA) {
                    order.DistributionChannel__c = order.SalesChannelType__c == ordSvc.CHANNER_OVERSEAS ? '20' : '10';
                }

                if(order.Country__c == null) {
                    order.Country__c = ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c) ? 'KR' : optyMap.get(order.OpportunityId);
                }
            }
        }
    }

    /**
    * @description AccountNameText__c, AccountId의 Name 적재,Listview 검색용
    * @author yeongju.yun | 2025-04-14 
    * @param news 
    **/
    private static void setAccountName(List<Order> news) {
        
        Set<Id> accIds = new Set<Id>();
        for(Order order : news) {
            accIds.add(order.AccountId);
        }

        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: accIds];
        Map<Id, Account> accMap = new Map<Id, Account>(accList);

        for(Order order : news) {
            order.AccountNameText__c = accMap.get(order.AccountId)?.Name;
        }
    }

    /**
    * @description ShipToName__c, ShipTo__c의 Name 적재,Listview 검색용
                   20250502 ShipTo_PSO__c 반영 및 DO에 업데이트 추가가
    * @author yeongju.yun | 2025-04-14 
    * @param news 
    **/
    private static void setShipToName(List<Order> news, Map<Id, Order> oldMap) {

        Boolean isNew = oldMap == null;
        
        List<Order> cpoTarget = new List<Order>();
        List<Order> psoTarget = new List<Order>();

        Set<Id> accIds = new Set<Id>();
        for(Order order : news) {
            if(order.ShipTo__c != null)     accIds.add(order.ShipTo__c);
            if(order.ShipTo_PSO__c != null) accIds.add(order.ShipTo_PSO__c);
            
            if(isNew) {
                cpoTarget.add(order);
            } else {

                if(oldMap.get(order.Id).ShipTo_PSO__c != order.ShipTo_PSO__c) {
                    psoTarget.add(order);
                } else if(oldMap.get(order.Id).ShipTo__c != order.ShipTo__c) {
                    cpoTarget.add(order);
                }
            }
        }

        List<Account> accList   = [SELECT Id, Name FROM Account WHERE Id =: accIds];
        Map<Id, Account> accMap = new Map<Id, Account>(accList);

        if(!cpoTarget.isEmpty()) {
            for(Order order : cpoTarget) {
                order.ShipToName__c = accMap.get(order.ShipTo__c)?.Name;
            }
        }
        
        Map<Id, String> doMap = new Map<Id, String>();
        if(!psoTarget.isEmpty()) {
            for(Order order : psoTarget) {
                order.ShipToName__c = accMap.get(order.ShipTo_PSO__c)?.Name;
                doMap.put(order.Id, order.ShipToName__c);
            }
        }
        
        if(!doMap.isEmpty()) {
            List<DeliveryOrder__c> doList = [SELECT Id, Order__c, ShipTo__c FROM DeliveryOrder__c WHERE Order__c =:doMap.keySet()];

            List<DeliveryOrder__c> toUpdateDO = new List<DeliveryOrder__c>();
            for(DeliveryOrder__c dOrder : doList) {
                dOrder.ShipTo__c = doMap.get(dOrder.Order__c);
                toUpdateDO.add(dOrder);
            }
            if(!toUpdateDO.isEmpty()) { update toUpdateDO; }
        }
    }
}