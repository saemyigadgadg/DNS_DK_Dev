/** 
 * @Class :  DN_UpdatePartsOrderBatch
 * 
 * @Test: DN_UpdatePartsOrderBatch_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 05. 30. 
 * @Version : 1.0 
 * @Description : DN_UpdatePartsOrderFromERPBatch 후속 배치로 앞에서 업데이트가 되지 않은 주문정보(출고 완료수량, 출고일 등) 업데이트 하는 보완용 프로그램 
                  - 16개월 전에 생성했지만 배송이 완료 되지 않은(미출고 혹은 부분출고) 주문건을 조회하여 관련 정보 업데이트 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-05-30 | Hyunwook Jin   | 최초작성 
 */ 

public with sharing class DN_UpdatePartsOrderBatch  implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful { 
    
    private DN_AsyncApexErrorLogger logger {
        get {
            if(logger == null) logger = new DN_AsyncApexErrorLogger();
            return logger;
        }
        set;
    }
    private Date startDate {get;set;}
    private Date endDate {get;set;}
    private Set<String> poOrderNos {
        get {
            if(poOrderNos == null) poOrderNos = new Set<String>();
            return poOrderNos;
        }
        set;
    }

    public DN_UpdatePartsOrderBatch() {}
    public DN_UpdatePartsOrderBatch(Date startDate, Date endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public DN_UpdatePartsOrderBatch(Set<String> poOrderNos) {
        this.poOrderNos = poOrderNos;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        Boolean isManual = false;
        Date today = Date.today(); // 예: 2025-05-14
        Date fourteenMonthsAgo = today.addMonths(-16); // 16개월전
        Date targetDate = Date.newInstance(fourteenMonthsAgo.year(), fourteenMonthsAgo.month(), 1);

        String query = ' SELECT Id, PartOrderNo__c, FM_OrderDate__c, FM_BuyerNo__c,IsDeletedSAP__c FROM PurchaseOrder__c ';
        String queryWhere = ' WHERE RecordType.DeveloperName = \'Order\'';

        if(poOrderNos.size() > 0) {
            System.debug(' poOrderNos : '+ JSON.serialize(poOrderNos));
            queryWhere += ' AND PartOrderNo__c IN :poOrderNos ';
            isManual = true;
        }

        if(startDate != null && endDate != null) {
            System.debug(' startDate :: '+ startDate);
            System.debug(' endDate :: '+ endDate);
            queryWhere += ' AND (DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :endDate) ';
            isManual = true;
        }

        String groupQuery = ' SELECT MIN(FM_OrderDate__c) stratDate, MAX(FM_OrderDate__c) endDate FROM PurchaseOrder__c where  RecordType.DeveloperName = \'Order\' ';
        String groupQueryWhere = '';

        if(isManual) {
            if(poOrderNos.size() > 0) {
                groupQueryWhere += ' AND PartOrderNo__c IN :poOrderNos ';
            }

            if(startDate != null && endDate != null) {
                groupQueryWhere += ' AND (DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :endDate) ';
            }
        }else {
            groupQueryWhere += ' AND FM_OrderStatus__c != \'C\' AND DAY_ONLY(CreatedDate) >= :targetDate   ';
        }
        System.debug('groupQuery :: '+ groupQuery+groupQueryWhere);
        List<AggregateResult> groupQ = Database.query(groupQuery + groupQueryWhere);
        
        // [
        //     SELECT MIN(FM_OrderDate__c) stratDate, MAX(FM_OrderDate__c) endDate
        //     FROM PurchaseOrder__c where FM_OrderStatus__c != 'C' 
        //     AND RecordType.DeveloperName = 'Order' 
        //     AND DAY_ONLY(CreatedDate) >= :targetDate
        // ];
        for(AggregateResult ages : groupQ) {
            this.startDate = (Date)ages.get('stratDate');
            this.endDate = (Date)ages.get('endDate');
        }

        if(!isManual) {
            System.debug('targetDate :: '+ targetDate);
            queryWhere += ' AND FM_OrderStatus__c != \'C\' AND DAY_ONLY(CreatedDate) >= :targetDate AND IsDeletedSAP__c = false ';
        }

        System.debug('query :: '+ query + queryWhere);
        

        return Database.getQueryLocator(query + queryWhere);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        try {
            // if(scope.size() == 1) {
                
                Set<String> poIds = new Set<String>();
                Map<String,Boolean> poMap = new Map<String,Boolean>();
                IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req();
                List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN> LT_VBELN_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN>();
                for(PurchaseOrder__c po : (List<PurchaseOrder__c>)scope) {
                    poIds.add(po.Id);
                    poMap.put(po.PartOrderNo__c, true);
                    req.I_FDATE     = String.valueOf(this.startDate);
                    req.I_TDATE     = String.valueOf(this.endDate);
                    req.I_DROP      = '0';
            
                    IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_I_USERINFO();
                    // I_USERINFO.KUNNR        = po.FM_BuyerNo__c;
                    I_USERINFO.VKORG        = '1846';
                    I_USERINFO.VTWEG        = '10';
                    I_USERINFO.SPART        = '40';
                    I_USERINFO.LAND1        = 'KR';
                    req.I_USERINFO          = I_USERINFO;
            
                    IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN LT_VBELN = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN();
                    LT_VBELN.VBELN = po.PartOrderNo__c;
                    LT_VBELN_List.add(LT_VBELN);
            
                }
                req.LT_VBELN = LT_VBELN_List;

                IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
                IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res result = instance.IF_PARTS_013(req);
                System.debug(result);
    
                Map<String, PurchaseOrderItems__c> poItemMap = new Map<String, PurchaseOrderItems__c>();
                List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL> t_List = (List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL>) result.T_DETAIL;
                for(IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL detail : t_List) {
                    String key = detail.VBELN  + '_'+ detail.POSNR + '_'+ detail.MATNR_SH;
                    // 플래그 변경
                    poMap.put(detail.VBELN, false);

                    if(!poItemMap.containsKey(key)) {
                        poItemMap.put(key, new PurchaseOrderItems__c(
                            ExpectedSupplyDate__c   = detail.FST_ETD == '0000-00-00' ? null : Date.valueOf(detail.FST_ETD),
                            RevisedSupplyDate__c    = detail.LST_ETD == '0000-00-00' ? null : Date.valueOf(detail.LST_ETD),
                            ShipmentDate__c         = detail.DODAT   == '0000-00-00' ? null : Date.valueOf(detail.DODAT),
                            Quantity__c             = Decimal.valueOf(detail.SO_QTY),
                            PenddingQty__c          = Decimal.valueOf(detail.STB_QTY),
                            ConfirmedQty__c         = Decimal.valueOf(detail.CFM_QTY),
                            PackingCompleted__c     = Decimal.valueOf(detail.PI_QTY),
                            CompletedQty__c         = Decimal.valueOf(detail.SH_QTY)
                        )); 
                    }else {
                        PurchaseOrderItems__c purchaseOrderItem = poItemMap.get(key);
                        purchaseOrderItem.ConfirmedQty__c         += Decimal.valueOf(detail.CFM_QTY);
                        purchaseOrderItem.PackingCompleted__c     += Decimal.valueOf(detail.PI_QTY);
                        purchaseOrderItem.CompletedQty__c         += Decimal.valueOf(detail.SH_QTY);
                        purchaseOrderItem.ExpectedSupplyDate__c   = detail.FST_ETD == '0000-00-00' ? null : Date.valueOf(detail.FST_ETD);
                        purchaseOrderItem.RevisedSupplyDate__c    = detail.LST_ETD == '0000-00-00' ? null : Date.valueOf(detail.LST_ETD);
                        purchaseOrderItem.ShipmentDate__c         = detail.DODAT   == '0000-00-00' ? null : Date.valueOf(detail.DODAT);
                    }
                }
                
                List<PurchaseOrder__c> flagList = new List<PurchaseOrder__c>();
                for(PurchaseOrder__c pos : (List<PurchaseOrder__c>)scope) {
                    if(poMap.get(pos.PartOrderNo__c)) {
                        flagList.add(new PurchaseOrder__c(
                            Id = pos.Id,
                            IsDeletedSAP__c = poMap.get(pos.PartOrderNo__c)
                        ));
                    }
                }
                if(flagList.size() > 0) update flagList;

                List<PurchaseOrderItems__c> updateList = new List<PurchaseOrderItems__c>();
                for(PurchaseOrderItems__c poItem : [  SELECT Id, PurchaseOrder__r.PartOrderNo__c,ItemNo__c, SupplyPartNo__c, ExpectedSupplyDate__c, RevisedSupplyDate__c, ShipmentDate__c,
                                    Quantity__c, PenddingQty__c, 
                                    ConfirmedQty__c, PackingCompleted__c,  CompletedQty__c
                            FROM PurchaseOrderItems__c
                            WHERE PurchaseOrder__c IN :poIds 
                ]) {
                    System.debug(JSON.serialize(poItem));
                    String key = poItem.PurchaseOrder__r.PartOrderNo__c +'_'+ poItem.ItemNo__c +'_'+poItem.SupplyPartNo__c;
                    
                    if(poItemMap.containsKey(key)) {
                        PurchaseOrderItems__c summaryData = poItemMap.get(key);
                        summaryData.Id = poItem.Id;
                        updateList.add(summaryData);
                    } 
                }
    
                if(updateList.size() > 0) update updateList;

                System.debug(JSON.serialize(updateList));
            // } else {
            //     throw new CustomException('Only Batch Size is 1. But Current Batch Size : '+ scope.size());
            // }
        } catch (Exception e) {
            String log = ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            logger.addLog(BC.getJobId() , 'DN_UpdatePartsOrderBatch', 'execute', 'BatchApex', log);
        } finally {
            logger.insertLog();
        }

    }

    public void finish(Database.BatchableContext bc) {
        

    }

    public class CustomException extends Exception {}
}