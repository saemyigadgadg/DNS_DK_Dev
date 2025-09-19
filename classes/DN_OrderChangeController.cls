/**
 * @component         : [DN_CreateOrderChange], [DN_OrderChangeBtn]
 * @test              : DN_OrderChangeControllerTest
 * @description       : 주문의 주문 수정 요청 버튼 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 04-19-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-01-16   yeongju.yun   Initial Version
**/
public with sharing class DN_OrderChangeController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description 주문 수정 요청 시 알림 발송
    **/
    @AuraEnabled
    public static void sendNotiToManager(String recordId, String changeId){
        try {

            OrderChangeRequest__c changeRow = [
                SELECT  Id, Order__c, OrderChangeReason__c, toLabel(OrderChangeReason__c) reason, ChangeDetail__c
                        , SalesOffice__c, SalesOrganization__c
                FROM    OrderChangeRequest__c 
                WHERE   Id =: changeId
            ];

            User thisUser = [SELECT Id, Name, ManagerId, SalesOffice__c, SalesOrganization__c FROM User WHERE Id =: UserInfo.getUserId()];

            changeRow.SalesOffice__c       = thisUser.SalesOffice__c;
            changeRow.SalesOrganization__c = thisUser.SalesOrganization__c;
            update changeRow;

            Order order = [SELECT Id, OrderNumber, ERPOrderNo__c, ERPRSONo__c, RecordTypeId, DNSA_SalesOffice__c FROM Order WHERE Id =: recordId];
            Id recordTypeDNSA = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

            String erpOrderNo = '';
            if(order.RecordTypeId == recordTypeDNSA) { erpOrderNo = order.ERPRSONo__c; }
            else { erpOrderNo = order.ERPOrderNo__c; }
            
            Map<String, String> infoMap = new Map<String, String>{
                'OrderNumber'  => order.OrderNumber
                , 'Requester'  => thisUser.Name
                , 'Reason'     => String.valueOf(changeRow.get('reason'))
                , 'ERPOrderNo' => erpOrderNo
                , 'Detail'     => changeRow.ChangeDetail__c ?? ''
            };

            Set<Id> targetUserIds = new Set<Id>();

            if(order.RecordTypeId == recordTypeDNSA) { // DNSA
                String groupName = order.DNSA_SalesOffice__c == '414A' ? 'Order Request (414A)' : 'Order Request (414P)';

                List<Message_Group_Junction__c> groupMembers = [
                    SELECT  Id, User__c
                    FROM    Message_Group_Junction__c
                    WHERE   Message_Group__r.Name = : groupName
                ];

                for(Message_Group_Junction__c groupMember : groupMembers) {
                    targetUserIds.add(groupMember.User__c);
                }
                
            } else {
                if(thisUser.ManagerId != null) {
                    targetUserIds.add(thisUser.ManagerId);
                }
            }

            Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
            targetUserMap.put(changeRow.Id, targetUserIds);

            if(!targetUserIds.isEmpty()) {

                UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                    'OrderChangeRequest'
                    , 'bell'
                    , new List<SObject>{changeRow}
                    , targetUserMap
                    , new Map<String, Object>{'infoMap' => infoMap}
                );
                
                if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){ System.debug('sendNotiToManager bellAlertResult : ' + bellAlertResult.errMessage);}
    
                UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                    'OrderChangeRequest'
                    , 'email'
                    , new List<SObject>{changeRow}
                    , targetUserMap
                    , new Map<String, Object>{'infoMap' => infoMap}
                );
                if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){ System.debug('sendNotiToManager emailAlertResult : ' + emailAlertResult.errMessage);}
            }

        } catch (Exception e) {
            System.debug('sendNotiToManager error ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}