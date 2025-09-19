/**
 * @description       : 
 * @test              : DeliveryOrderTriggerHandlerTest
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-07-17
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-27-2024   Hanyeong Choi   Initial Version
**/
public with sharing class DeliveryOrderTriggerHandler extends TriggerHandler {
    public static DN_OrderService ordSvc = new DN_OrderService();

    public override void onBeforeInsert(List<sObject> news){
        if (isExecuting) {
            System.debug('DeliveryOrder BEFORE_INSERT TRIGGER Start');

            List<DeliveryOrder__c> doList = (List<DeliveryOrder__c>)news;

            syncOwnerForExport(doList);
            fetchOrderInfo(doList);
            
            setting(false, TriggerOperation.BEFORE_INSERT);
            System.debug('DeliveryOrder BEFORE_INSERT TRIGGER End');
        }
    }

    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        System.debug('onAfterInsert' + isExecuting);
        if (isExecuting) {
            System.debug('DeliveryOrder AFTER_INSERT TRIGGER Start');

            List<DeliveryOrder__c> doList = (List<DeliveryOrder__c>)news;

            updateOrderStatus(doList);
            
            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('DeliveryOrder AFTER_INSERT TRIGGER End');
        }
    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('DeliveryOrder BEFORE_UPDATE TRIGGER Start'); 

            List<DeliveryOrder__c> doList = (List<DeliveryOrder__c>)news;
            Map<Id, DeliveryOrder__c> doMap = (Map<Id, DeliveryOrder__c>) oldMap;
            Boolean isAdmin = ordSvc.getAdminFlag();

            // [SLS-DLV-022] ERP 전송 후 D/O 수정,삭제 불가
            for(DeliveryOrder__c deliveryOrder : doList) {
                if(isAdmin) continue;
                if(String.isBlank(deliveryOrder.ERPDONo__c)) continue;
                
                if(String.isNotBlank(doMap.get(deliveryOrder.Id).ERPDONo__c) && String.isNotBlank(deliveryOrder.ERPDONo__c)) {

                    deliveryOrder.addError(System.Label.DNS_M_DONeverEdit); // Delivery order transmitted to the ERP cannot be edited in the CRM.
                }
            }
            
            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('DeliveryOrder BEFORE_UPDATE TRIGGER End'); 
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('DeliveryOrder AFTER_UPDATE TRIGGER Start'); 

            List<DeliveryOrder__c>    doList = (List<DeliveryOrder__c>)news;
            Map<Id, DeliveryOrder__c> doMap  = (Map<Id, DeliveryOrder__c>)oldMap;

            List<DeliveryOrder__c>    doOldList = (List<DeliveryOrder__c>)olds;


            sendDoConfirmedAlert(doList, doMap);
            alertInternalApproval(doList, doMap);
            sendDOTOERP(doList, doMap);
            sendApprovedRequest(doList, doOldList);
            
            setting(false, TriggerOperation.AFTER_UPDATE);
            System.debug('DeliveryOrder AFTER_UPDATE TRIGGER End'); 
        }
    }

    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
        if(isExecuting) {
            System.debug('DeliveryOrder BEFORE_DELETE TRIGGER Start'); 
            Boolean isAdmin = ordSvc.getAdminFlag();
            List<DeliveryOrder__c> doList = (List<DeliveryOrder__c>) dels;

            // [SLS-DLV-022] ERP 전송 후 D/O 수정,삭제 불가
            for(DeliveryOrder__c deliveryOrder : doList) {
                if(isAdmin) continue;
                deliveryOrder.addError(System.Label.DNS_M_DONeverDelete); // Delivery order cannot be deleted in the CRM.
            }

            setting(false, TriggerOperation.BEFORE_DELETE);
            System.debug('DeliveryOrder BEFORE_DELETE TRIGGER End'); 
        }
    }

    /**
     * @Description
     * 	- [SLS-ORD-002] DO 생성 시, Order의 Status를 'Delivery'로 update
     * @author Hanyeong Choi | 06-27-2024
     * @Parameter
     *  - recordIds	        : Order Ids
    **/ 
    private static void updateOrderStatus(List<DeliveryOrder__c> news) {

        Set<Id> orderIds = new Set<Id>();
        for(DeliveryOrder__c d : news) {
            orderIds.add(d.Order__c);
        }
        List<Order> orderList = [ SELECT Id, Status FROM Order WHERE Id IN :orderIds];
        if(!orderList.isEmpty()) {
            List<Order> updateOrderList = new List<Order>();
            List<String> preventChange = new List<String>{ordSvc.ORDER_DELIVERY, ordSvc.ORDER_CANCELED};
            for(Order order : orderList) {
                if(!preventChange.contains(order.Status)) {
                    System.debug('Owner : ' + order);
                    order.Status = ordSvc.ORDER_DELIVERY;
                    order.IF_FreePass__c = true;
                    updateOrderList.add(order);
                }
            }
            update updateOrderList;
        }
    }

    /**
    * @description [SLS-DLV-018] 수출 only, Reference Order No의 Owner를 Delivery Order의 Owner로 설정
    * @author yeongju.yun | 2024-11-11 
    * @param news 
    **/
    private void syncOwnerForExport(List<DeliveryOrder__c> news) {

        Set<Id> orderIds = new Set<Id>();
        List<DeliveryOrder__c> target = new List<DeliveryOrder__c>();
        for(DeliveryOrder__c d : news) {
            orderIds.add(d.Order__c);
        }

        List<Order> orderList = [SELECT Id, OwnerId, SalesChannelType__c FROM Order WHERE Id =: orderIds];
        Map<Id, Order> orderMap = new Map<Id, Order>(orderList);

        for(DeliveryOrder__c d : news) {
            Order thisOrder = orderMap.get(d.Order__c);
            
            if(thisOrder == null) { continue; }
            if(ordSvc.CHANNER_DOMESTIC_SET.contains(thisOrder.SalesChannelType__c)) { continue; }

            d.OwnerId = thisOrder.OwnerId;
        }
    }

    /**
    * @description D/O Internal Approved > D/O Confirmed, 영업 Eamil Notification
    * @author yeongju.yun | 2024-12-18 
    * @param news 
    * @param oldMap 
    **/
    private void sendDoConfirmedAlert(List<DeliveryOrder__c> news, Map<Id, DeliveryOrder__c> oldMap) {

        List<DeliveryOrder__c> target  = new List<DeliveryOrder__c>();
        Set<Id> nameUsers  = new Set<Id>();
        Set<Id> orderIdSet  = new Set<Id>();

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        for(DeliveryOrder__c d : news) {
            if(oldMap.get(d.Id).Status__c != ordSvc.DO_CONFIRMED && d.Status__c == ordSvc.DO_CONFIRMED) {
                target.add(d);
                nameUsers.add(d.OwnerId);
                orderIdSet.add(d.Order__c);

                Set<Id> targetUsers = targetUserMap.containsKey(d.Id) ? targetUserMap.get(d.Id) : new Set<Id>();
                targetUsers.add(d.OwnerId);
                targetUserMap.put(d.Id, targetUsers);
            }
        }

        if(!target.isEmpty() && !nameUsers.isEmpty() && !orderIdSet.isEmpty()) {
            Map<Id, String> userNameMap = ordSvc.getUserNameMap(nameUsers);
            if(userNameMap.isEmpty()) return; // active = false 

            Map<Id, String> ordNameMap  = new Map<Id, String>();
            Map<Id, Boolean> dnsFlag    = new Map<Id, Boolean>();
            

            List<Order> orderList = [SELECT Id, OrderNumber, RecordType.Name FROM Order WHERE Id =: orderIdSet];
            for(Order order : orderList) {
                ordNameMap.put(order.Id, order.OrderNumber);
                dnsFlag.put(order.Id, order.RecordType.Name == 'DNS');
            }

            // Notification
            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'DeliveryOrderConfirmed'
                , 'bell'
                , target
                , targetUserMap
                , new Map<String, Object>{'userNameMap' => userNameMap, 'ordNameMap' => ordNameMap, 'dnsFlag' => dnsFlag}
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(bellAlertResult.errMessage); }

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'DeliveryOrderConfirmed'
                , 'email'
                , target
                , targetUserMap
                , new Map<String, Object>{'userNameMap' => userNameMap, 'ordNameMap' => ordNameMap, 'dnsFlag' => dnsFlag}
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(emailAlertResult.errMessage); }
        }
    }

    /**
    * @description DO정보 ERP로 전송
    **/
    private void sendDOTOERP(List<DeliveryOrder__c> news, Map<Id, DeliveryOrder__c> oldMap) {
        try {
            
            List<DeliveryOrder__c> target = new List<DeliveryOrder__c>();
            Set<Id> doIdSet = new Set<Id>();
            for(DeliveryOrder__c dOrder : news) {
                if(oldMap.get(dOrder.Id).InternalApprovalStatus__c == ordSvc.INTERNAL_PROCESSING && dOrder.InternalApprovalStatus__c == ordSvc.INTERNAL_APPROVED) {
                    target.add(dOrder);
                    doIdSet.add(dOrder.Id);
                }
            }
            System.debug('sendDOTOERP doIdSet ::: ' + doIdSet);

            if(!target.isEmpty()) {
                List<ContentDocumentLink> cdlList = [
                    SELECT  Id, ContentDocumentId, LinkedEntityId
                    FROM    ContentDocumentLink
                    WHERE   LinkedEntityId =: doIdSet
                ];

                Set<Id> cdIdSet = new Set<Id>();
                Map<Id, Id> doCDLinkMap = new Map<Id, Id>(); // key : contentDocument id, value : do id
                if(!cdlList.isEmpty()) {

                    for(ContentDocumentLink cdl : cdlList) {
                        cdIdSet.add(cdl.ContentDocumentId);
                        doCDLinkMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }

                Map<Id, Id> cvDoMap = new Map<Id, Id>();  // key : cv id, value : do id
                List<String> tempCVIdList = new List<String>();
                if(!cdIdSet.isEmpty()) {

                    List<String> fileCategories = new List<String>{ordSvc.FILE_BIZREG, ordSvc.FILE_MAP, ordSvc.FILE_BOND};
                    List<ContentVersion> cvList = [
                        SELECT  Id, ContentDocumentId, Title, VersionData, ContentSize, FileExtension, FileType__c
                        FROM    ContentVersion
                        WHERE   FileType__c =: fileCategories
                        AND     ContentDocumentId =: cdIdSet
                    ];
                    System.debug('sendDOTOERP - cvList ::: ' + cvList);

                    for(ContentVersion cv : cvList) {
                        tempCVIdList.add(cv.Id);
                        
                        for(Id cdId : doCDLinkMap.keySet()) {
                            if(cv.ContentDocumentId == cdId) {
                                cvDoMap.put(cv.Id, doCDLinkMap.get(cdId));
                            }
                        }
                    }
                }

                Map<Id, List<ContentVersion>> toSendCVMap = new Map<Id, List<ContentVersion>>(); // key : delivery order id, value : content version list
                Map<Id, ContentVersion> htmlFileMap = new Map<Id, ContentVersion>();
                if(!tempCVIdList.isEmpty()) {

                    // create html files by the uploaded files
                    
                    IF_FilePackingService service = new IF_FilePackingService();
                    htmlFileMap = service.packingToMapByHTML(tempCVIdList);
                    System.debug('sendDOTOERP - htmlFileMap ::: ' + htmlFileMap);

                    for(ContentVersion htmlFile : htmlFileMap.values()) {

                        Id cvId = htmlFile.OriginVersionId__c;
                        Id doId = cvDoMap.get(cvId);

                        List<ContentVersion> innerCVList = toSendCVMap.containsKey(doId) ? toSendCVMap.get(doId) : new List<ContentVersion>();
                        innerCVList.add(htmlFile);
                        toSendCVMap.put(doId, innerCVList);
                    }
                    System.debug('sendDOTOERP - toSendCVMap ::: ' + toSendCVMap);
                }

                for(DeliveryOrder__c dOrder : target) {
                    if(toSendCVMap.containsKey(dOrder.Id)) {
                        System.enqueueJob(new DN_DeliveryOrderService(dOrder, dOrder.Order__c, htmlFileMap.values()));
                        // toSendCVMap.get(dOrder.Id)
                    } else {
                        System.enqueueJob(new DN_DeliveryOrderService(dOrder, dOrder.Order__c, new List<ContentVersion>()));
                    }
                }
            }
        } catch (Exception ex) {
            TriggerExceptionLog__c exLog = new TriggerExceptionLog__c();
            exLog.LineNumber__c = ex.getLineNumber();
            exLog.Message__c = 'DeliveryOrderTriggerHandler : ' + ex.getMessage();
            exLog.ExceptionType__c = ex.getTypeName();
            exLog.ProgramEndTimemilles__c = System.currentTimeMillis();
            insert exLog;
        }
    }

    /**
    * @description 내부 승인에 대한 알림, 이메일 발송
    **/
    private void alertInternalApproval(List<DeliveryOrder__c> news, Map<Id, DeliveryOrder__c> oldMap) {
        System.debug('alertInternalApproval');

        List<DeliveryOrder__c> confirmedDOrders = new List<DeliveryOrder__c>();
        List<DeliveryOrder__c> rejectedDOrders  = new List<DeliveryOrder__c>();
        
        Map<String, Set<Id>> confirmedUserMap = new Map<String, Set<Id>>();
        Map<String, Set<Id>> rejectedUsetMap  = new Map<String, Set<Id>>();

        for(DeliveryOrder__c dOrder : news) {
            if(oldMap.get(dOrder.Id).InternalApprovalStatus__c == ordSvc.INTERNAL_PROCESSING && dOrder.InternalApprovalStatus__c == ordSvc.INTERNAL_APPROVED) {
                confirmedDOrders.add(dOrder);
                Set<Id> userIds = confirmedUserMap.containsKey(dOrder.Id) ?  confirmedUserMap.get(dOrder.Id) : new Set<Id>();
                userIds.add(dOrder.OwnerId);
                confirmedUserMap.put(dOrder.Id, userIds);
            } else if(oldMap.get(dOrder.Id).InternalApprovalStatus__c == ordSvc.INTERNAL_PROCESSING && dOrder.InternalApprovalStatus__c == ordSvc.INTERNAL_NOTSTARTED) {
                rejectedDOrders.add(dOrder);
                Set<Id> userIds = rejectedUsetMap.containsKey(dOrder.Id) ?  rejectedUsetMap.get(dOrder.Id) : new Set<Id>();
                userIds.add(dOrder.OwnerId);
                rejectedUsetMap.put(dOrder.Id, userIds);
            }
        }

        List<ProcessInstanceStep> steps = [
            SELECT  ProcessInstance.TargetObjectId, ActorId, Actor.Name, Comments
            FROM    ProcessInstanceStep
            WHERE   ProcessInstance.TargetObjectId  = :oldMap.keySet()
            ORDER BY CreatedDate DESC
        ];

        Map<Id, String> actorNameMap = new Map<Id, String>(); // key : order id, value : actor name
        Map<Id, String> commentsMap  = new Map<Id, String>(); // key : order id, value : comments
        for(ProcessInstanceStep step : steps) {
            if(!actorNameMap.containsKey(step.ProcessInstance.TargetObjectId)) {
                actorNameMap.put(step.ProcessInstance.TargetObjectId, step.Actor.Name);
            }

            if(!commentsMap.containsKey(step.ProcessInstance.TargetObjectId)) {
                commentsMap.put(step.ProcessInstance.TargetObjectId, step.Comments ?? '');
            }
        }

        if(!confirmedDOrders.isEmpty()) {
            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'DeliveryOrderInternalApproved'
                , 'bell'
                , confirmedDOrders
                , confirmedUserMap
                , new Map<String, Object>{'userNameMap' => actorNameMap, 'nameMap' => commentsMap}
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { confirmedDOrders[0].addError(bellAlertResult.errMessage); }

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'DeliveryOrderInternalApproved'
                , 'email'
                , confirmedDOrders
                , confirmedUserMap
                , new Map<String, Object>{'userNameMap' => actorNameMap, 'nameMap' => commentsMap}
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { confirmedDOrders[0].addError(emailAlertResult.errMessage); }
        } 
        
        if(!rejectedDOrders.isEmpty()) {
            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'DeliveryOrderInternalRejected'
                , 'bell'
                , rejectedDOrders
                , rejectedUsetMap
                , new Map<String, Object>{'userNameMap' => actorNameMap, 'nameMap' => commentsMap}
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { rejectedDOrders[0].addError(bellAlertResult.errMessage); }

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'DeliveryOrderInternalRejected'
                , 'email'
                , rejectedDOrders
                , rejectedUsetMap
                , new Map<String, Object>{'userNameMap' => actorNameMap, 'nameMap' => commentsMap}
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { rejectedDOrders[0].addError(emailAlertResult.errMessage); }
        }
    }

    /**
    * @description Order의 특정 필드를 DO 검색용 텍스트 필드에 싱크
    **/
    private void fetchOrderInfo(List<DeliveryOrder__c> news) {
        
        Set<Id> orderIds = new Set<Id>();
        for(DeliveryOrder__c dOrder : news) {
            orderIds.add(dOrder.Order__c);
        }

        List<Order> orderList = [SELECT Id, ERPOrderNo__c, ERPPSONo__c, ShipTo_PSO__r.Name, Product__c FROM Order WHERE Id =: orderIds];
        Map<Id, Order> orderMap = new Map<Id, Order>(orderList);
        if(!orderList.isEmpty()) {
            for(DeliveryOrder__c dOrder : news) {
                if(orderMap.containsKey(dOrder.Order__c)) {
                    Order thisOrder   = orderMap.get(dOrder.Order__c);
                    dOrder.CPONo__c   = thisOrder.ERPOrderNo__c;
                    dOrder.PSONo__c   = thisOrder.ERPPSONo__c;
                    dOrder.ShipTo__c  = thisOrder.ShipTo_PSO__r.Name;
                    dOrder.Product__c = thisOrder.Product__c;
                }
            }
        }
    } 

     /**
    * @description InternalApprovalStatus__c가 Approved가 아니고, Status__c가 DOInternalApproved일때
                 지사장과 지사장의 backup인력에게 Noti
    * @author sejin.kwon | 2025-07-15 
    * @param news 
    * @param oldMap 
    **/
    private void sendApprovedRequest(List<DeliveryOrder__c> news, List<DeliveryOrder__c> olds) {

        DeliveryOrder__c getAccInfo = [SELECT Order__r.SoldTo__r.Name, Order__r.ERPPSONo__c FROM DeliveryOrder__c WHERE Id =: news[0].Id LIMIT 1];
        // User reqInfo = [SELECT Id, Backup_User_Id__c FROM User WHERE Profile.Name = '영업 지사장' AND SalesOffice__c =: news[0].SalesOffice__c LIMIT 1];
        
        // Set<Id> targetId = new Set<Id>();
        // targetId.add(reqInfo.Id);
        // targetId.add(reqInfo.Backup_User_Id__c);
        // List<User> getReqInfo = new List<User>();
        // getReqInfo =  DN_WithoutSharingClass.getUserEmails(targetId);
        
        MessageGroup__c mgId = [SELECT Id FROM MessageGroup__c WHERE Name = 'SO-DO 알림대상' AND SalesOffice__c =: news[0].SalesOffice__c LIMIT 1];
        List<Message_Group_Junction__c> mgInfo = [SELECT Id, FM_UserEmail__c FROM Message_Group_Junction__c WHERE Message_Group__c =: mgId.Id];
        LIst<String> targetEmail = new List<String>();
        if(!mgInfo.isEmpty()){
            for(Integer i = 0; i < mgInfo.size(); i++){
                targetEmail.add(mgInfo[i].FM_UserEmail__c);
            }
        }
        
        List<UTIL_Alert.HistoryWrapper> historyWrappers = new List<UTIL_Alert.HistoryWrapper>();
        
        if(olds[0].Status__c != ordSvc.DO_APPROVED && news[0].Status__c == ordSvc.DO_APPROVED){
            if(!targetEmail.isEmpty()){
                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Do Approved Request'];
                Id alertId;
                if(!am.isEmpty()){
                    alertId = am[0].Id;
                }else{
                    alertId = 'a0xJO000000JE5hYAG';
                }
                for(Integer i = 0; i < targetEmail.size(); i++){
                    System.debug(' targetEmail[i] : ' + targetEmail[i]);
                    UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
                    wrapEmail.alertID            = alertId;
                    wrapEmail.targetID           = news[0].Id;
                    wrapEmail.alertType          = 'Email';
                    wrapEmail.receiverforEmail   = new List<String>{targetEmail[i]};
                    wrapEmail.alertLanguage      = 'ko';
                    wrapEmail.elementList        = new List<String>{news[0].Name != null ? news[0].Name : '', 
                                                                    news[0].ERPDONo__c != null ? news[0].ERPDONo__c : '', 
                                                                    news[0].Product__c != null ? news[0].Product__c : '', 
                                                                    news[0].PlannedGI__c != null ? String.valueOf(news[0].PlannedGI__c) : '', 
                                                                    getAccInfo.Order__r.SoldTo__r.Name != null ? getAccInfo.Order__r.SoldTo__r.Name : '', 
                                                                    news[0].ShipTo__c != null ? news[0].ShipTo__c : '',
                                                                    getAccInfo.Order__r.ERPPSONo__c != null ? getAccInfo.Order__r.ERPPSONo__c : ''};

                    // UTIL_Alert.HistoryWrapper wrapNoti = new UTIL_Alert.HistoryWrapper();
                    // wrapNoti.alertID            = alertId;
                    // wrapNoti.targetID           = news[0].Id;
                    // wrapNoti.alertType          = 'Notification';
                    // wrapNoti.receiverforEmail   = new List<String>{getReqInfo[i].Id};
                    // wrapNoti.alertLanguage      = 'ko';
                    // wrapNoti.elementList        = new List<String>{news[0].Name, news[0].ERPDONo__c, news[0].Product__c, news[0].PlannedGI__c};

                    historyWrappers.add(wrapEmail);
                    // historyWrappers.add(wrapNoti);
                }
                UTIL_Alert.runAlertEvent(historyWrappers);
                
            }
        }

    }

}