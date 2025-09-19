/**
 * @description       : 출하의뢰 관련 I/F 호출 
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-17
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-16   yeongju.yun   Initial Version
 * 1.1   2025-05-08   yeongju.yun   EDIT01. DO 실패 시 Support 대상 Notification
 * 1.2   2025-05-12   yeongju.yun   EDIT02. File Title Encoding
**/
public with sharing class DN_DeliveryOrderService implements Queueable, Database.AllowsCallouts{
    
    public static DN_OrderService ordSvc = new DN_OrderService();
    public DeliveryOrder__c dOrder;
    public String orderId;
    public List<ContentVersion> newFiles;
    
    public DN_DeliveryOrderService(DeliveryOrder__c dOrder, String orderId, List<ContentVersion> newFiles) {
        this.dOrder        = dOrder;
        this.orderId       = orderId;
        this.newFiles      = newFiles;
    }

    public void execute(QueueableContext context) {

        try {
            Order order = [
                SELECT  Id, ERPPSONo__c, ERPOrderNo__c, OrderType__c, OwnerId, Owner__r.ERP_Key__c, Owner__c
                        , Owner__r.CustomerCode__c, Owner__r.Account.CustomerCode__c
                        , SalesOrganization__c, DistributionChannel__c, Division__c
                        , SoldTo__c, SoldTo__r.Name, SoldTo__r.CustomerCode__c, SoldTo__r.ShippingCity, SoldTo__r.ShippingPostalCode, SoldTo__r.ShippingStreet
                        , ShipTo__c, ShipTo__r.Name, ShipTo__r.CustomerCode__c, ShipTo__r.ShippingCity, ShipTo__r.ShippingPostalCode, ShipTo__r.ShippingStreet
                        , BillTo__c, BillTo__r.Name, BillTo__r.CustomerCode__c, BillTo__r.ShippingCity, BillTo__r.ShippingPostalCode, BillTo__r.ShippingStreet
                FROM    Order
                WHERE   Id =:orderId
            ];

            // File
            List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP> T_TMP_LIST = setFiles(newFiles);
            
            // UserInfo
            IF_ERP_DELIV_Classes.IF_DELIV_001_Req_I_USERINFO I_USERINFO = setUserInfo(order);
            
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

            List<DeliveryOrder__c> notiDOrder = [SELECT Id, Name, OwnerId FROM DeliveryOrder__c WHERE Id =: dOrder.Id];
            Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
            for(DeliveryOrder__c dOrder : notiDOrder) {
                targetUserMap.put(dOrder.Id, new Set<Id>{dOrder.OwnerId});
            }

            if(response.O_RETURN.TYPE == 'S') {
                updateDeliveryOrder(dOrder.Id, response.O_VBELN, '');
                updateOrder(order.Id, response.O_VBELN);

                UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                    'DeliveyOrderERPSent'
                    , 'bell'
                    , notiDOrder
                    , targetUserMap
                    , null
                );
                if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { System.debug('DeliveyOrderERPSent Alert Error ::: ' + bellAlertResult.errMessage); }

            } else {
                updateDeliveryOrder(dOrder.Id, '', response.O_RETURN.MESSAGE);

                UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                    'DeliveryOrderERPFail'
                    , 'bell'
                    , notiDOrder
                    , targetUserMap
                    , null
                );
                if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { System.debug('DeliveyOrderERPSent Alert Error ::: ' + bellAlertResult.errMessage); }

                // EDIT01. DO 실패 시 Support 대상 Notification
                DeliveryOrder__c tempDO = dOrder.clone(true, true, true, true);
                tempDO.IF_ERROR__c = response.O_RETURN.MESSAGE;
                sendSupportNoti(tempDO);
            }

        } catch(Exception ex) {
            TriggerExceptionLog__c exLog = new TriggerExceptionLog__c();
            exLog.LineNumber__c = ex.getLineNumber();
            exLog.Message__c = 'DN_DeliveryOrderService : ' + ex.getMessage();
            exLog.ExceptionType__c = ex.getTypeName();
            exLog.ProgramEndTimemilles__c = System.currentTimeMillis();
            insert exLog;
        }

    }

    /**
    * @description 메시지 그룹에 ERP 전송 실패 알림 및 이메일 발송
    **/
    public static void sendSupportNoti(DeliveryOrder__c dOrder) {

        // target user
        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();

        List<Message_Group_Junction__c> members = [
            SELECT  Id, Message_Group__r.Name, Message_Group__r.SalesOffice__c, User__c
            FROM    Message_Group_Junction__c
            WHERE   Message_Group__r.Name IN ('DO 알림대상', 'SO-DO 알림대상')
        ];

        String salesOffice = dOrder.SalesOffice__c;
        if(salesOffice == null) {
            Order tempOrder = [SELECT Id, SalesOffice__c FROM Order WHERE Id =: dOrder.Order__c];
            salesOffice = tempOrder?.SalesOffice__c;
        }
        Set<Id> targetUsers = new Set<Id>();
        for(Message_Group_Junction__c member : members) {
            if((member.Message_Group__r.Name == 'SO-DO 알림대상' && member.Message_Group__r.SalesOffice__c == salesOffice)
                || (member.Message_Group__r.Name == 'DO 알림대상')) {
                targetUsers.add(member.User__c);
            }
        }

        if(!targetUsers.isEmpty()) {
            targetUserMap.put(dOrder.Id, targetUsers);

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'DeliveryOrderERPFailSupport'
                , 'email'
                , new List<DeliveryOrder__c>{dOrder}
                , targetUserMap
                , null
            );

            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                System.debug('Alert ERROR ::: ' + emailAlertResult.errMessage);
            }

            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'DeliveryOrderERPFailSupport'
                , 'bell'
                , new List<DeliveryOrder__c>{dOrder}
                , targetUserMap
                , null
            );

            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                System.debug('Alert ERROR ::: ' + bellAlertResult.errMessage);
            }
        }
    }

    /**
    * @description 파일 정보 맵핑
    **/
    public static List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP> setFiles(List<ContentVersion> cvList){
        List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP> T_TMP_LIST = new List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP>();
        if(cvList != null && !cvList.isEmpty()) {

            Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>(cvList);
            List<ContentVersion> tempCVList = [
                SELECT  Id, Title, FileType__c, VersionData
                FROM    ContentVersion
                WHERE   Id =: cvMap.keySet()
            ];

            for(ContentVersion cv : tempCVList) {

                String base64Content  = EncodingUtil.base64Encode(cv.VersionData);
                Integer contentLength = base64Content.length();
                Integer chunkSize     = 1024;

                String type   = '';
                if(cv.FileType__c == ordSvc.FILE_BIZREG)    { type = 'Biz Registration Num'; } 
                else if(cv.FileType__c == ordSvc.FILE_MAP)  { type = 'Map Document'; } 
                else if(cv.FileType__c == ordSvc.FILE_BOND) { type = 'Bond Document'; }

                for (Integer i = 0; i < contentLength; i += chunkSize) {
                    Integer endItg = Math.min(i + chunkSize, contentLength);

                    IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP T_TMP = new IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP();
                    T_TMP.FILENAME  = EncodingUtil.urlEncode(cv.Title, 'UTF-8'); // EDIT02. File Title Encoding
                    T_TMP.IF_DESC   = type;
                    T_TMP.EVISEQX   = '02';
                    T_TMP.LINE      = EncodingUtil.urlEncode(base64Content.substring(i, endItg), 'UTF-8');
                    T_TMP.FILE_SIZE = String.valueOf(contentLength);
                    T_TMP_LIST.add(T_TMP);
                }
            }
        }
        return T_TMP_LIST;
    }

    /**
    * @description Order의 정보 맵핑
    **/
    public static IF_ERP_DELIV_Classes.IF_DELIV_001_Req_I_USERINFO setUserInfo(Order order){
        IF_ERP_DELIV_Classes.IF_DELIV_001_Req_I_USERINFO I_USERINFO = new IF_ERP_DELIV_Classes.IF_DELIV_001_Req_I_USERINFO();
        
        Map<Id, Boolean> userTypeMap = ordSvc.getUserFlag(new Set<Id>{order.OwnerId});
        Boolean isCRMUser = userTypeMap.get(order.OwnerId);
        String customerCode = isCRMUser ? ordSvc.formatCodeForSAP(10, order.Owner__r.CustomerCode__c) : ordSvc.formatCodeForSAP(10, order.Owner__r.Account.CustomerCode__c);

        I_USERINFO.BNAME = order.OwnerId;
        I_USERINFO.RNAME = ordSvc.formatCodeForSAP(12, String.valueOf(order.Owner__r.ERP_Key__c));
        I_USERINFO.KUNNR = customerCode;
        I_USERINFO.VKORG = order.SalesOrganization__c;
        I_USERINFO.VTWEG = order.DistributionChannel__c;
        I_USERINFO.SPART = order.Division__c;
        I_USERINFO.HIER  = 'A';
        return I_USERINFO;
    }

    /**
    * @description DO에 ERP에서 받아온 DO번호 업데이트
    **/
    public static void updateDeliveryOrder(String dOrderId, String erpDONo, String errorMsg) {
        DeliveryOrder__c prevDO = new DeliveryOrder__c(
            Id = dOrderId
            , ERPDONo__c  = erpDONo
            , IF_ERROR__c = errorMsg
        );
        update prevDO;
    }

    /**
    * @description Order에 DO정보 업데이트
    **/
    public static void updateOrder(String orderId, String dOrderNo) {
        Order toUpdateOrder    = new Order();
        toUpdateOrder.Id       = orderId;
        toUpdateOrder.IF_DO__c = dOrderNo;
        toUpdateOrder.IF_FreePass__c = true;

        Database.SaveResult orderSR = Database.update(toUpdateOrder, false);
        if(!orderSR.isSuccess()) {
            System.debug('ORDER UPDATE ERROR  ::: ' + orderSR.getId() + ' / ' + orderSR.getErrors());
        }
    }
}