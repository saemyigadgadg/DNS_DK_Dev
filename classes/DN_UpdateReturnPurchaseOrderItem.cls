/**
 * @description       : 필드 입력 값만 수정
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 04-13-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-13-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_UpdateReturnPurchaseOrderItem implements 
                        Database.Batchable<IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2>, 
                        Database.AllowsCallouts, 
                        Database.Stateful,
                        Schedulable {
    private InterfaceCommonLog.interfaceLog             interfaceLog    = new InterfaceCommonLog.interfaceLog('IF-PARTS-019', 'IF_ERP_Parts_Return');
    private static Map<String,Schema.SObjectType>       schemaMap       = Schema.getGlobalDescribe();

    private final IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req   req;

    /** 
     * Schedule
     *  String cronExp30 = '0 30 * * * ?'; // 매일 00:30, 00:00
     *  String cronExp00 = '0 00 * * * ?'; // 매일 00:30, 00:00
     *  String jobName30 = 'IF_DN_UpdateReturnPurchaseOrderItem_Schedule30';';
     *  String jobName00 = 'IF_DN_UpdateReturnPurchaseOrderItem_Schedule00';';
     *  IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req req = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req();
     *  System.schedule(jobName30, cronExp30, new DN_UpdateReturnPurchaseOrderItem(req));
     *  System.schedule(jobName00, cronExp00, new DN_UpdateReturnPurchaseOrderItem(req));
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req req = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req();
  
            Date today = Date.today();
            String requestParameter = today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + String.valueOf(today.day()).leftPad(2, '0');

            IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req_LS_SEARCH LS_SEARCH = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req_LS_SEARCH();
            LS_SEARCH.FRDATE    = requestParameter;
            LS_SEARCH.TODATE    = requestParameter;
            LS_SEARCH.VBTYP     = 'A';
            req.LS_SEARCH       = LS_SEARCH;
            
            req.COMPLAINT     = 'Y';

            IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req_I_USERINFO();
            I_USERINFO.VKORG        = '1846';
            I_USERINFO.VTWEG        = '10';
            I_USERINFO.SPART        = '40';

            req.I_USERINFO          = I_USERINFO;

            DN_UpdateReturnPurchaseOrderItem instance = new DN_UpdateReturnPurchaseOrderItem(req);
            Database.executeBatch(instance);
        }

    // Constructure
    public DN_UpdateReturnPurchaseOrderItem(IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req req) {
        this.req = req;
    }

    // Batch method
    public List<IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2> start(Database.BatchableContext BC) {
        System.debug('DN_UpdateReturnPurchaseOrderItem Start ------------');
        try {
            IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res res = callOutApi(this.req);
            return res.LT_SEARCH2;
        } catch (Exception e) {
            this.interfaceLog.errorText = new List<String>();
            this.interfaceLog.errorText.add('[' + e.getLineNumber() + ']' + e.getMessage());   
            InterfaceCommonLog ifCommonLog = new InterfaceCommonLog();
            ifCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{this.interfaceLog});

            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
            return null;
        }
    }
    public void execute(Database.BatchableContext bc, List<IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2> scope) {
        System.debug('DN_UpdateReturnPurchaseOrderItem Execute ------------');

        System.SavePoint savePoint = Database.setSavepoint();

        try{
            // 1. response에서 parts order item mapping 에 필요한 object map 정리
            Map<String, IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2> LT_SEARCH2ForKey = new Map<String, IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2>();
            List<String> POSNRList = new List<String>();
            for (IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2 LT_SEARCH2 : scope) {
                String key = LT_SEARCH2.VBELN + '/' + LT_SEARCH2.POSNR;
                LT_SEARCH2ForKey.put(key, LT_SEARCH2);
                POSNRList.add(LT_SEARCH2.POSNR);
            }

            // 2. parts order item qeury해서 List를 생성
            Map<String, Schema.SObjectField> purchaseOrderItemObjectFields = schemaMap.get('PurchaseOrderItems__c').getDescribe().fields.getMap();
            List<String> purchaseOrderItemFieldsToQuery = new List<String>(purchaseOrderItemObjectFields.keySet());

            String  purchaseOrderItemQuery = 'SELECT ' + String.join(purchaseOrderItemFieldsToQuery, ', ') + ', PurchaseOrder__r.PartOrderNo__c FROM PurchaseOrderItems__c';
                    purchaseOrderItemQuery += ' WHERE OrderNo__c IN (\''+ String.join(POSNRList, '\',\'') +'\')';
                    purchaseOrderItemQuery += ' ORDER BY CreatedDate DESC LIMIT 50000';

            List<PurchaseOrderItems__c> purchaseOrderItemList  = (List<PurchaseOrderItems__c>) Database.query(purchaseOrderItemQuery);

            // 3. parts order item List를 mapping용 map으로 필드 변경
            for (PurchaseOrderItems__c purchaseOrderItem : purchaseOrderItemList) {
                mappingPurchaseOrderItem(purchaseOrderItem, LT_SEARCH2ForKey);
            }

            // 4. parts order item List Update
            if(purchaseOrderItemList.size() > 0)    Database.update(purchaseOrderItemList);

        } catch (Exception e) {
            Database.rollback(savePoint);

            this.interfaceLog.errorText = new List<String>();
            this.interfaceLog.errorText.add('[' + e.getLineNumber() + ']' + e.getMessage());   
            InterfaceCommonLog ifCommonLog = new InterfaceCommonLog();
            ifCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{this.interfaceLog});

            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
        }
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('DN_UpdateReturnPurchaseOrderItem Finish ------------');
    }

    // Util method
    public IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res callOutApi(IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req req){
        IF_ERP_Parts_Return instance = new IF_ERP_Parts_Return();
        return instance.IF_PARTS_019(this.req);
    }
    public Void mappingPurchaseOrderItem(PurchaseOrderItems__c purchaseOrderItem, Map<String, IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2> LT_SEARCH2ForKey){
        String key = purchaseOrderItem.getSObject('PurchaseOrder__r').get('PartOrderNo__c') + '/' + purchaseOrderItem.OrderNo__c;
        System.debug('purchaseOrderItem key ::: ' + key);
        IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2 LT_SEARCH2 = LT_SEARCH2ForKey.get(key);
        System.debug('LT_SEARCH2 ::: ' + LT_SEARCH2);
        
        if(LT_SEARCH2 != null){
            purchaseOrderItem.Invoice__c        = LT_SEARCH2.VGBEL;
            purchaseOrderItem.HQOrderNo__c      = LT_SEARCH2.VBELN2;
            purchaseOrderItem.Status__c         = LT_SEARCH2.RFGSK_TX_T1 == 'Returned' ? '반품 수락' : '미진행';
        }
    }
}