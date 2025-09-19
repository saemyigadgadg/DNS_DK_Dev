/** 변수명 정리
 *      예시StaffNo       : ServiceResource.StaffNumber__c      - Staff Number *ERP Key
*/
public with sharing class DN_UpdatePartsOrderFromERPBatch implements 
                        Database.Batchable<ScopeObject>, 
                        Database.AllowsCallouts, Database.Stateful, Schedulable{   
    private InterfaceCommonLog.interfaceLog             interfaceLog    = new InterfaceCommonLog.interfaceLog('IF-PARTS-034', 'IF_ERP_Parts_Order');
    private static Map<String,Schema.SObjectType>       schemaMap       = Schema.getGlobalDescribe();

    private final IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req   req;

    /** 
     * Schedule
     *  String cronExp30 = '0 30 7-20 * * ?'; // 매일 07:30 ~ 20:30
     *  String cronExp00 = '0 00 7-20 * * ?'; // 매일 07:00 ~ 20:00
     *  String jobName30 = 'IF_DN_UpdatePartsOrderFromERPBatch_Schedule30';';
     *  String jobName00 = 'IF_DN_UpdatePartsOrderFromERPBatch_Schedule00';';
     *  IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req();
     *  System.schedule(jobName30, cronExp30, new DN_UpdatePartsOrderFromERPBatch(req));
     *  System.schedule(jobName00, cronExp00, new DN_UpdatePartsOrderFromERPBatch(req));
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req();
  
            Date today = Date.today();
            String requestParameter = today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + String.valueOf(today.day()).leftPad(2, '0');
            req.I_FDATE             = requestParameter;
            req.I_TDATE             = requestParameter;

            req.I_USERINFO          = new IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req_I_USERINFO();
            req.I_USERINFO.VKORG    = '1846';
            req.I_USERINFO.VTWEG    = '10';
            req.I_USERINFO.SPART    = '40';
        
            DN_UpdatePartsOrderFromERPBatch instance = new DN_UpdatePartsOrderFromERPBatch(req);
            Database.executeBatch(instance);
        }

    // Constructure
    public DN_UpdatePartsOrderFromERPBatch(IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req req) {
        this.req = req;
    }

    // Wrapper
    public class ScopeObject{
        public String parameterName;
        public IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER T_HEADER;
        public IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL T_DETAIL;

        public ScopeObject(){}
    }
    public class SummaryObject{
        public Decimal CFM_QTY;
        public Decimal PI_QTY;
        public Decimal SH_QTY;

        public SummaryObject(){}
    }

    // Batch method
    public List<ScopeObject> start(Database.BatchableContext bc) {
        System.debug('DN_UpdatePartsOrderFromERPBatch Start ------------');
        try {
            IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res res = callOutApi(this.req);

            List<ScopeObject> scopeObjectList = new List<ScopeObject>();
            for (IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER T_HEADER : res.T_HEADER) {
                ScopeObject scopeObject     = new ScopeObject();
                scopeObject.parameterName   = 'T_HEADER';
                scopeObject.T_HEADER        = T_HEADER;
                scopeObjectList.add(scopeObject);
            }
            for (IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL T_DETAIL : res.T_DETAIL) {
                ScopeObject scopeObject     = new ScopeObject();
                scopeObject.parameterName   = 'T_DETAIL';
                scopeObject.T_DETAIL        = T_DETAIL;
                scopeObjectList.add(scopeObject);
            }
            System.debug('scopeObjectList ::: ' + scopeObjectList);
            return scopeObjectList;
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
    public void execute(Database.BatchableContext BC, List<ScopeObject> scope){
        System.debug('DN_UpdatePartsOrderFromERPBatch Execute ------------');

        System.SavePoint savePoint = Database.setSavepoint();

        try {
            // 1. response에서 parts order mapping 에 필요한 object map 정리
            Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER> T_HEADERForVBELN = new Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER>();
            Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL> T_DETAILForKey = new Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL>();
            Map<String, SummaryObject> summaryForKey = new Map<String, SummaryObject>();
            Set<String> POSNRSet = new Set<String>();
            Set<String> VBELNSet = new Set<String>();
            for (ScopeObject scopeObject : scope) {
                if(scopeObject.parameterName == 'T_HEADER'){
                    T_HEADERForVBELN.put(scopeObject.T_HEADER.VBELN, scopeObject.T_HEADER);
                }else if(scopeObject.parameterName == 'T_DETAIL'){
                    String key = scopeObject.T_DETAIL.VBELN + '/' + scopeObject.T_DETAIL.POSNR;

                    POSNRSet.add(scopeObject.T_DETAIL.POSNR);
                    VBELNSet.add(scopeObject.T_DETAIL.VBELN);
                    
                    T_DETAILForKey.put(key, scopeObject.T_DETAIL);

                    // 2025.04.24 Summary 로직 변경 
                    // 1. SummaryObject 에 key에 해당하는 각종 정보 합산
                    if(summaryForKey.get(key) == null){
                        SummaryObject summary = new SummaryObject();

                        summary.CFM_QTY     = Decimal.valueOf(scopeObject.T_DETAIL.CFM_QTY);
                        summary.PI_QTY      = Decimal.valueOf(scopeObject.T_DETAIL.PI_QTY);
                        summary.SH_QTY      = Decimal.valueOf(scopeObject.T_DETAIL.SH_QTY);

                        summaryForKey.put(key, summary);
                    } else {
                        SummaryObject summary = summaryForKey.get(key);

                        summary.CFM_QTY     += Decimal.valueOf(scopeObject.T_DETAIL.CFM_QTY);
                        summary.PI_QTY      += Decimal.valueOf(scopeObject.T_DETAIL.PI_QTY);
                        summary.SH_QTY      += Decimal.valueOf(scopeObject.T_DETAIL.SH_QTY);

                        summaryForKey.put(key, summary);
                    }
                }
            }

            // 2. parts order, parts order item qeury해서 List를 생성
            Map<String, Schema.SObjectField> purchaseOrderFields = schemaMap.get('PurchaseOrder__c').getDescribe().fields.getMap();
            List<String> purchaseOrderfieldsToQuery = new List<String>(purchaseOrderFields.keySet());

            String  purchaseOrderQuery = 'SELECT ' + String.join(purchaseOrderfieldsToQuery, ', ') + ' FROM PurchaseOrder__c';
                    purchaseOrderQuery += ' WHERE PartOrderNo__c IN (\''+ String.join(T_HEADERForVBELN.keySet(), '\',\'') +'\')';
                    purchaseOrderQuery += ' ORDER BY CreatedDate DESC LIMIT 50000';

            List<PurchaseOrder__c> purchaseOrderList           = (List<PurchaseOrder__c>) Database.query(purchaseOrderQuery);

            Map<String, Schema.SObjectField> purchaseOrderItemObjectFields = schemaMap.get('PurchaseOrderItems__c').getDescribe().fields.getMap();
            List<String> purchaseOrderItemFieldsToQuery = new List<String>(purchaseOrderItemObjectFields.keySet());

            String  purchaseOrderItemQuery = 'SELECT ' + String.join(purchaseOrderItemFieldsToQuery, ', ') + ', PurchaseOrder__r.PartOrderNo__c FROM PurchaseOrderItems__c';
                    purchaseOrderItemQuery += ' WHERE ItemNo__c IN (\''+ String.join(POSNRSet, '\',\'') +'\') AND PurchaseOrder__r.PartOrderNo__c IN (\''+ String.join(VBELNSet, '\',\'') +'\')';
                    purchaseOrderItemQuery += ' ORDER BY CreatedDate DESC LIMIT 50000';

            List<PurchaseOrderItems__c> purchaseOrderItemList  = (List<PurchaseOrderItems__c>) Database.query(purchaseOrderItemQuery);

            // 3. parts order, parts order item List를 mapping용 map으로 필드 변경
            for (PurchaseOrder__c purchaseOrder : purchaseOrderList) {
                mappingPurchaseOrder(purchaseOrder, T_HEADERForVBELN);
            }
            for (PurchaseOrderItems__c purchaseOrderItem : purchaseOrderItemList) {
                mappingPurchaseOrderItem(purchaseOrderItem, T_DETAILForKey, summaryForKey);
            }

            // 4. parts order, parts order item List Update
            System.debug('purchaseOrderList ::: ' + purchaseOrderList);
            System.debug('purchaseOrderItemList ::: ' + purchaseOrderItemList);
            if(purchaseOrderList.size() > 0)        Database.update(purchaseOrderList);
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
        System.debug('DN_UpdatePartsOrderFromERPBatch Finish ------------');
        try {
            Database.executeBatch(new DN_UpdatePartsOrderBatch(), 10);
        } catch (Exception e) {
            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());
        }
    }

    // Util method
    public IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res callOutApi(IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req req){
        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        return instance.IF_PARTS_034(req);
    }
    public Void mappingPurchaseOrder(PurchaseOrder__c purchaseOrder, Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER> T_HEADERForVBELN){
        System.debug('purchaseOrder.PartOrderNo__c ::: ' + purchaseOrder.PartOrderNo__c);
        IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER T_HEADER = T_HEADERForVBELN.get(purchaseOrder.PartOrderNo__c);
        System.debug('T_HEADER ::: ' + T_HEADER);
        
        if(T_HEADER != null){
            purchaseOrder.BLOCK__c  = T_HEADER.LIFSK;
        }
    }
    public Void mappingPurchaseOrderItem(PurchaseOrderItems__c purchaseOrderItem, Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL> T_DETAILForKey, Map<String, SummaryObject> summaryForKey){
        String key = purchaseOrderItem.getSObject('PurchaseOrder__r').get('PartOrderNo__c') + '/' + purchaseOrderItem.ItemNo__c;
        System.debug('purchaseOrderItem key ::: ' + key);
        IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL T_DETAIL = T_DETAILForKey.get(key);
        System.debug('T_DETAIL ::: ' + T_DETAIL);
        
        if(T_DETAIL != null && purchaseOrderItem.SupplyPartNo__c == T_DETAIL.MATNR_SH){
            system.debug('I am here');
            purchaseOrderItem.ExpectedSupplyDate__c   = T_DETAIL.FST_ETD == '0000-00-00' ? null : Date.valueOf(T_DETAIL.FST_ETD);
            purchaseOrderItem.RevisedSupplyDate__c    = T_DETAIL.LST_ETD == '0000-00-00' ? null : Date.valueOf(T_DETAIL.LST_ETD);
            purchaseOrderItem.ShipmentDate__c         = T_DETAIL.DODAT   == '0000-00-00' ? null : Date.valueOf(T_DETAIL.DODAT);
            purchaseOrderItem.Quantity__c             = Decimal.valueOf(T_DETAIL.SO_QTY);
            purchaseOrderItem.PenddingQty__c          = Decimal.valueOf(T_DETAIL.STB_QTY);

            SummaryObject summary = summaryForKey.get(key);
            purchaseOrderItem.ConfirmedQty__c         = summary.CFM_QTY;
            purchaseOrderItem.PackingCompleted__c     = summary.PI_QTY;
            purchaseOrderItem.CompletedQty__c         = summary.SH_QTY;
            
            purchaseOrderItem.Invoice__c              = T_DETAIL.INVOICE;
            purchaseOrderItem.HQOrderNo__c            = T_DETAIL.VBELN2;
            purchaseOrderItem.Status__c               = T_DETAIL.RFGSK_TX_T;
            purchaseOrderItem.DepartureSiteCode__c    = T_DETAIL.VSTEL;
            purchaseOrderItem.DepartureSite__c        = T_DETAIL.VTEXT;
        }
    }
}

// SupplyPartNo__c , MATNR_SH