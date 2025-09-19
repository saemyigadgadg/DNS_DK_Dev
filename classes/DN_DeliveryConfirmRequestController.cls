/**
 * @component         : DN_DeliveryConfirmRequestBtn
 * @description       : Delivery Order에서 D/O를 ERP로 전송하기 위한 버튼 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-18   yeongju.yun   Initial Version
**/
public with sharing class DN_DeliveryConfirmRequestController {
    public static DN_OrderService ordSvc = new DN_OrderService();

    /**
    * @description D/O를 ERP에 전송한 적 없을 때 ( = ERPDONo__c가 빈값이 아닐 때)
                   D/O의 Status가 'Delivery Order Internal Approved'일 때 
    * @author yeongju.yun | 2024-12-18 
    * @param doId 
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper validateDeliveryConfrim(String doId){
        ResultWrapper result = new ResultWrapper();
        try {
            
            DeliveryOrder__c dOrder = [SELECT Id, ERPDONo__c, IF_ERROR__c, Status__c FROM DeliveryOrder__c WHERE Id =:doId];

            if(String.isNotBlank(dOrder.ERPDONo__c)) {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_DOSent; // The delivery order has already been sent.
            } else if(dOrder.Status__c == ordSvc.DO_CREATED) {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_InternalApprovalFirst; // Please proceed with internal approval first.
            } else if(String.isBlank(dOrder.IF_ERROR__c)) {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_NOError; // No error occurred for this item, so no further action is required.
            }
        } catch (Exception e) {
            result.isSuccess  = false;
            result.errMessage = e.getMessage();
        }
        return result;
    }

    /**
    * @description ERP전송 전 파일 변환
    **/
    @AuraEnabled
    public static List<ContentVersion> setConfirmData(String doId){
        try {

            List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: doId];
            if(cdlList.isEmpty()) { return null; }

            Set<Id> cdIdSet = new Set<Id>();
            for(ContentDocumentLink cdl : cdlList) {
                cdIdSet.add(cdl.ContentDocumentId);
            }

            List<String> fileCategories = new List<String>{ordSvc.FILE_BIZREG, ordSvc.FILE_MAP, ordSvc.FILE_BOND};
            List<ContentVersion> cvList = [
                SELECT  Id, Title, VersionData, ContentSize, FileExtension, FileType__c, ContentDocumentId
                FROM    ContentVersion
                WHERE   FileType__c =: fileCategories
                AND     ContentDocumentId =: cdIdSet
            ];

            List<String> tempCVIdList = new List<String>();
            for(ContentVersion cv : cvList) {
                tempCVIdList.add(cv.Id);
            }

            // create html files by the uploaded files
            IF_FilePackingService service = new IF_FilePackingService();
            Map<Id, ContentVersion> htmlFileMap = service.packingToMapByHTML(tempCVIdList);

            return htmlFileMap.values();
        } catch (Exception e) {
            System.debug('setConfirmData : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description DO ERP 전송 및 알림 발송
    **/
    @AuraEnabled
    public static ResultWrapper requestConfrim(String doId, List<ContentVersion> cvList){
        ResultWrapper result = new ResultWrapper();
        try {
            Boolean hasFiles = cvList != null && !cvList.isEmpty();

            DeliveryOrder__c dOrder = [
                SELECT  Id, Name, CapitalNo__c, DestinationZone__c, PlannedGI__c, DeliveryDate__c, Note__c, OwnerId, Order__c, SalesOffice__c
                FROM    DeliveryOrder__c
                WHERE   Id =: doId
            ];

            Order order = [
                SELECT  Id, ERPPSONo__c, ERPOrderNo__c, OrderType__c, OwnerId, Owner__r.ERP_Key__c, Owner__c
                        , Owner__r.CustomerCode__c, Owner__r.Account.CustomerCode__c
                        , SalesOrganization__c, DistributionChannel__c, Division__c
                        , SoldTo__c, SoldTo__r.Name, SoldTo__r.CustomerCode__c, SoldTo__r.ShippingCity, SoldTo__r.ShippingPostalCode, SoldTo__r.ShippingStreet
                        , ShipTo__c, ShipTo__r.Name, ShipTo__r.CustomerCode__c, ShipTo__r.ShippingCity, ShipTo__r.ShippingPostalCode, ShipTo__r.ShippingStreet
                        , BillTo__c, BillTo__r.Name, BillTo__r.CustomerCode__c, BillTo__r.ShippingCity, BillTo__r.ShippingPostalCode, BillTo__r.ShippingStreet
                FROM    Order
                WHERE   Id =:dOrder.Order__c
            ];

            // File
            List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP> T_TMP_LIST = DN_DeliveryOrderService.setFiles(cvList);
            
            // UserInfo
            IF_ERP_DELIV_Classes.IF_DELIV_001_Req_I_USERINFO I_USERINFO = DN_DeliveryOrderService.setUserInfo(order);

            Map<String, String> plannedGIMap = ordSvc.formatDateTimeForSAP(dOrder.PlannedGI__c, true);
            Map<String, String> deliveryDateMap = ordSvc.formatDateTimeForSAP(dOrder.DeliveryDate__c, true);
    
            IF_ERP_DELIV_Classes.IF_DELIV_001_Req IF_DELIV_001 = new IF_ERP_DELIV_Classes.IF_DELIV_001_Req();
            IF_DELIV_001.I_CHK         = 'X'; // REQUIRED
            IF_DELIV_001.I_VBELN       = order.OrderType__c == 'ZPSA' ? order.ERPOrderNo__c : order.ERPPSONo__c; // REQUIRED
            IF_DELIV_001.I_CAPITAL_NO  = dOrder.CapitalNo__c;
            IF_DELIV_001.I_DEST        = dOrder.DestinationZone__c; // REQUIRED
            IF_DELIV_001.I_WADAT       = plannedGIMap.get('date'); // REQUIRED
            IF_DELIV_001.I_WAUHR       = plannedGIMap.get('time'); // REQUIRED
            IF_DELIV_001.I_LFDAT       = deliveryDateMap.get('date'); // REQUIRED
            IF_DELIV_001.I_LFUHR       = deliveryDateMap.get('time'); // REQUIRED
            IF_DELIV_001.I_NOTE        = dOrder.Note__c;
    
            IF_DELIV_001.I_USERINFO = I_USERINFO;
            IF_DELIV_001.T_TMP      = T_TMP_LIST;
    
            IF_ERP_DELIV method = new IF_ERP_DELIV();
            IF_ERP_DELIV_Classes.IF_DELIV_001_Res response = method.IF_DELIV_001(IF_DELIV_001);

            Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
            targetUserMap.put(dOrder.Id, new Set<Id>{dOrder.OwnerId});

            if(response.O_RETURN.TYPE == 'S') {
                DN_DeliveryOrderService.updateDeliveryOrder(dOrder.Id, response.O_VBELN, '');
                DN_DeliveryOrderService.updateOrder(order.Id, response.O_VBELN);

                UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                    'DeliveyOrderERPSent'
                    , 'bell'
                    , new List<DeliveryOrder__c>{dOrder}
                    , targetUserMap
                    , null
                );
                if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { System.debug('DeliveyOrderERPSent Alert Error ::: ' + bellAlertResult.errMessage); }

            } else {
                DN_DeliveryOrderService.updateDeliveryOrder(dOrder.Id, '', response.O_RETURN.MESSAGE);

                UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                    'DeliveryOrderERPFail'
                    , 'bell'
                    , new List<DeliveryOrder__c>{dOrder}
                    , targetUserMap
                    , null
                );
                if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { System.debug('DeliveyOrderERPSent Alert Error ::: ' + bellAlertResult.errMessage); }

                // EDIT01. DO 실패 시 Support 대상 Notification
                DeliveryOrder__c tempDO = dOrder.clone(true, true, true, true);
                tempDO.IF_ERROR__c = response.O_RETURN.MESSAGE;
                DN_DeliveryOrderService.sendSupportNoti(tempDO);

                result.isSuccess  = false;
                result.errMessage = response.O_RETURN.MESSAGE;
            }

            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  {get;set;}
        @AuraEnabled public String  errMessage {get;set;}

        public ResultWrapper(){
            this.isSuccess  = true;
            this.errMessage = '';
        }
    }

}