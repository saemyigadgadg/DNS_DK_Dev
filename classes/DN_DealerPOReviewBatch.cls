/** 
 * @Class :  DN_DealerPOReviewBatch
 * 
 * @Test: DN_DealerPOReviewBatch_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 24. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-24 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_DealerPOReviewBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable  {

    private String plantCode {
        get {
            if(String.isBlank(plantCode)) {
                plantCode = '1846';
            }
            return plantCode;
        } 
        set;
    }

    private String agencyCode {get; set;}
    private List<String> agencyCodes {
        get {
            if(agencyCodes == null) {
                agencyCodes = new List<String>();
            }
            return agencyCodes;
        }
        set;
    } 
    private Integer splitLimit {
        get {
            if(splitLimit == null) {
                splitLimit = 1;
            }
            return splitLimit;
        }
        set;
    }
    private Integer batchSize {
        get {
            if(batchSize == null) {
                batchSize = 100;
            }
            return batchSize;
        }
        set;
    }

    private DN_AsyncApexErrorLogger logger {
        get {
            if(logger == null) {
                logger = new DN_AsyncApexErrorLogger();
            }
            return logger;
        }
        set;
    }

    /*
    * @ 생성자 : DN_DealerPOReviewBatch
    * @ Description : plantCode 설정
    */
    public DN_DealerPOReviewBatch(){}
    public DN_DealerPOReviewBatch(String plantCode) {
        this.plantCode = plantCode;
    }

    /*
    * @ 생성자 : DN_DealerPOReviewBatch
    * @ Description : plantCode,agencyCode 설정
    */
    public DN_DealerPOReviewBatch(String plantCode, String agencyCode) {
        this.plantCode = plantCode;
        this.agencyCode = agencyCode;
    }

    /*
    * @ 생성자 : DN_DealerPOReviewBatch
    * @ Description : plantCode,agencyCode 리스트 설정
    */
    public DN_DealerPOReviewBatch(String plantCode, List<String> agencyCodes) {
        this.plantCode = plantCode;
        this.agencyCodes = agencyCodes;
    }

    /*
    * @ Method : start
    * @ Description : 배치 시작
    */
    public Database.QueryLocator start(Database.BatchableContext context){
        System.debug(' =============== DN_DealerPOReviewBatch Batch start ================');
        System.debug('Start plantCode : ' + plantCode);
        String query = 'SELECT '
                     + ' Plant__c, MRPType__c, Dealer__c, Part__c, FM_PartCode__c, LastPart__c, '
                     + ' DealerStock__c, FM_DealerCode__c, IsPOListReview__c, ExternalKey__c, DueIn__c, '
                     + ' MaximumStock__c, MinimumLotSize__c, RoundingValue__c, ReorderPoint__c, ABCIndicator__c, POQuantity__c '
                     + ' FROM DealerPartMasterByMPPS__c WHERE Plant__c = :plantCode AND Dealer__c != null ';
        
        if(agencyCodes.size() > 0) {
            List<String> targetAgencyCodes = new List<String>();

            Integer agencySize = agencyCodes.size();
            for(Integer i = agencySize-1; i >= 0; i--) {
                targetAgencyCodes.add(agencyCodes.get(i));
                agencyCodes.remove(i);
                System.debug(' New : ' +targetAgencyCodes.size() + ' : Before : '+agencyCodes.size());
                if(targetAgencyCodes.size() == splitLimit) break;
            }
            Set<String> dealerAccountId = new Set<String>();
            for(User dealerUser : [SELECT AccountId FROM User where UserType = 'PowerPartner' AND Profile.Name ='DNS CS Parts_Partner' AND Account.CustomerCode__c IN :targetAgencyCodes AND IsActive = true]) {
                dealerAccountId.add(dealerUser.AccountId);
            }

            query += ' AND Dealer__c IN (\''+String.join(dealerAccountId, '\',\'')+'\')';
            
        }
        else if(String.isNotBlank(agencyCode)) {
            query += ' AND FM_DealerCode__c = \''+agencyCode+'\'';
        }   
        
        query += ' ORDER BY Dealer__c ';
        //TEST
        // query += ' AND ExternalKey__c  IN (\'C60118034_1244220\') '; //, \'101512-00002C_1244220\'

        return Database.getQueryLocator(query);
    }

    /*
    * @ Method : execute
    * @ Description : 배치 실행
    */
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== DN_DealerPOReviewBatch Batch Execute ================');

        try {
            // Set<String> plantCodes = new Set<String>();
            Set<String> partIds = new Set<String>();
            Set<String> dealerIds = new Set<String>();
            for(DealerPartMasterByMPPS__c dealerPartMaster : (List<DealerPartMasterByMPPS__c>)scope) {
                // if(String.isNotBlank(dealerPartMaster.Plant__c)) plantCodes.add(dealerPartMaster.Plant__c);
                if(String.isNotBlank(dealerPartMaster.Part__c)) partIds.add(dealerPartMaster.Part__c);
                if(String.isNotBlank(dealerPartMaster.Dealer__c)) dealerIds.add(dealerPartMaster.Dealer__c);
                
            }

            Map<String, Map<String, DealerStock__c>> dealerStockMap = new Map<String, Map<String, DealerStock__c>>();
            for(DealerStock__c stock :[
                SELECT
                    Id, SalesOrganization__c, Part__c, Part__r.ProductCode, ExternalKey__c, Dealer__r.CustomerCode__c, 
                    CurrentStockQuantity__c, BlockQuantity__c, AvailableQuantity__c,
                    OrderRequiredQuantity__c , WarrantyRequiredQuantity__c
                FROM DealerStock__c 
                WHERE Part__c IN :partIds AND SalesOrganization__c = :plantCode AND Dealer__c IN :dealerIds
            ]) {
                if(!dealerStockMap.containsKey(stock.Dealer__r.CustomerCode__c)) dealerStockMap.put(stock.Dealer__r.CustomerCode__c, new Map<String, DealerStock__c>());
                
                dealerStockMap.get(stock.Dealer__r.CustomerCode__c).put(stock.Part__r.ProductCode, stock);
                
            }


            // Due In (OPEN 수량) : 주문수량 - 입고 수량
            // 주문수량 : 타대리점주문서, DNS주문서

            Set<String> orderItemIds = new Set<String>();
            Set<String> dnsOrderItemIds = new Set<String>();
            // Key: DealerCode, subKey: PartCode, value: quantity        
            Map<String, Map<String, Decimal>> dealerPartOrderQuantityMap = new Map<String, Map<String, Decimal>>();

            //1. 주문수량 계산
            for(DealerPurchaseOrder__c order : [
                    SELECT
                        OrderNumber__c,
                        Dealer__r.CustomerCode__c,
                        Customer__r.SourceAccount__r.CustomerCode__c
                        , (
                            SELECT
                                Id,
                                OrderItemNumber__c, 
                                ReplacingPart__r.Name,
                                Quantity__c,
                                Delete__c
                            FROM Item__r
                            WHERE Delete__c != 'Y' AND ReplacingPart__c IN :partIds
                        )
                    FROM DealerPurchaseOrder__c 
                    WHERE ( CreatedDate = LAST_N_MONTHS:7 OR CreatedDate = THIS_MONTH) AND Delete__c != 'Y'
                    AND Dealer__c IN :dealerIds
                    ORDER BY CreatedDate
            ]) {
                if(!dealerPartOrderQuantityMap.containsKey(order.Dealer__r.CustomerCode__c)) 
                    dealerPartOrderQuantityMap.put(order.Dealer__r.CustomerCode__c , new Map<String, Decimal>());

                Map<String, Decimal> partOrderQuantityMap = dealerPartOrderQuantityMap.get(order.Dealer__r.CustomerCode__c);
                for(DealerPurchaseOrderItem__c orderItem : order.item__r ) {
                    orderItemIds.add(orderItem.Id);
                    if(partOrderQuantityMap.containsKey(orderItem.ReplacingPart__r.Name)) {
                        Decimal orderQuantity = partOrderQuantityMap.get(orderItem.ReplacingPart__r.Name) + orderItem.Quantity__c;
                        partOrderQuantityMap.put(orderItem.ReplacingPart__r.Name , orderQuantity);
                    }else {
                        partOrderQuantityMap.put(orderItem.ReplacingPart__r.Name , orderItem.Quantity__c);
                    }

                }
            }

            // 2. 주문수량 계산 - 
            for(PurchaseOrder__c dnsOrder : [
                SELECT
                    PartOrderNo__c,
                    FM_BuyerNo__c,
                    (
                        SELECT
                            Id,
                            ItemNo__c,
                            SupplyPartId__c,
                            FM_SupplyPartNo__c,
                            Quantity__c
                        FROM PurchaseOrderItems__r
                        WHERE SupplyPartId__c IN :partIds
                    )
                FROM PurchaseOrder__c 
                WHERE RecordType.DeveloperName = 'Order' AND ( CreatedDate = LAST_N_MONTHS:7 OR CreatedDate = THIS_MONTH)
                AND Buyer__c IN :dealerIds
                ORDER BY CreatedDate
            ])  {
                
                if(!dealerPartOrderQuantityMap.containsKey(dnsOrder.FM_BuyerNo__c)) 
                    dealerPartOrderQuantityMap.put(dnsOrder.FM_BuyerNo__c , new Map<String, Decimal>());

                Map<String, Decimal> partOrderQuantityMap = dealerPartOrderQuantityMap.get(dnsOrder.FM_BuyerNo__c);
                for(PurchaseOrderItems__c orderItem : dnsOrder.PurchaseOrderItems__r ) {
                    dnsOrderItemIds.add(orderItem.Id);
                    if(partOrderQuantityMap.containsKey(orderItem.FM_SupplyPartNo__c)) {
                        Decimal orderQuantity = partOrderQuantityMap.get(orderItem.FM_SupplyPartNo__c) + orderItem.Quantity__c;
                        partOrderQuantityMap.put(orderItem.FM_SupplyPartNo__c , orderQuantity);
                    }else {
                        partOrderQuantityMap.put(orderItem.FM_SupplyPartNo__c , orderItem.Quantity__c);
                    }
                }
            }

            //3. 입고 수량 계산
            for(DealerInventoryMovements__c inventoryMove : [ 
                    SELECT
                        Id, 
                        RecordType.DeveloperName,
                        Quantity__c,  
                        Type__c, 
                        InventoryChange__c,
                        Dealer__r.CustomerCode__c,
                        Part__r.Name
                    FROM DealerInventoryMovements__c 
                    WHERE RecordType.DeveloperName  = 'GoodsReceipt' 
                    AND (DealerPurchaseOrderItem__c IN :orderItemIds OR PurchaseOrderItem__c IN :dnsOrderItemIds)
                    AND Part__c IN :partIds
                    ORDER BY CreatedDate
            ]) {
                //ZSLT0320LT-MENGE: 입고수량, IM_TYPE:  입고('S'), 입고취소('H')
                if(!dealerPartOrderQuantityMap.containsKey(inventoryMove.Dealer__r.CustomerCode__c)) 
                    dealerPartOrderQuantityMap.put(inventoryMove.Dealer__r.CustomerCode__c , new Map<String, Decimal>());

                Map<String, Decimal> partOrderQuantityMap = dealerPartOrderQuantityMap.get(inventoryMove.Dealer__r.CustomerCode__c);

                if(partOrderQuantityMap.containsKey(inventoryMove.Part__r.Name)) {
                    Decimal orderQuantity = partOrderQuantityMap.get(inventoryMove.Part__r.Name);
                    orderQuantity = calculateQuantityByInventroyMove(inventoryMove.InventoryChange__c, orderQuantity, inventoryMove.Quantity__c);
                    partOrderQuantityMap.put(inventoryMove.Part__r.Name , orderQuantity);
                }else {
                    Decimal orderQuantity = calculateQuantityByInventroyMove(inventoryMove.InventoryChange__c, 0.0, inventoryMove.Quantity__c);
                    partOrderQuantityMap.put(inventoryMove.Part__r.Name , orderQuantity);
                }

            }

            for(DealerPartMasterByMPPS__c dealerPartMaster : (List<DealerPartMasterByMPPS__c>)scope) {
                System.debug('  ExternalKey__c : ' + dealerPartMaster.ExternalKey__c + ' , ' +dealerPartMaster.FM_PartCode__c + ' , '+ dealerPartMaster.FM_DealerCode__c); //+dealerPartMaster.
                Decimal poQty = 0;
                Decimal availableQty = 0;
                Decimal dueIn = 0;
                Decimal dueOut = 0;
                Boolean isLastpart = false;

                isLastpart = (dealerPartMaster.LastPart__c!= null && dealerPartMaster.Part__c == dealerPartMaster.LastPart__c);

                if(String.isNotBlank(dealerPartMaster.FM_DealerCode__c) && dealerStockMap.containsKey(dealerPartMaster.FM_DealerCode__c)) {
                    System.debug('dealerPartMaster.FM_DealerCode__c : '+ dealerPartMaster.FM_DealerCode__c);
                    Map<String, DealerStock__c> stockMap = dealerStockMap.get(dealerPartMaster.FM_DealerCode__c);
                    if(String.isNotBlank(dealerPartMaster.FM_PartCode__c) && stockMap.containsKey(dealerPartMaster.FM_PartCode__c)) {
                        DealerStock__c stock = stockMap.get(dealerPartMaster.FM_PartCode__c);
                        dealerPartMaster.DealerStock__c = stock.Id;

                        dueOut = stock.OrderRequiredQuantity__c + stock.WarrantyRequiredQuantity__c;
                        //
                        availableQty = stock.CurrentStockQuantity__c;

                        System.debug('dealerPartMaster.DealerStock__c : '+dealerPartMaster.DealerStock__c);
                        System.debug('stockMap.get(dealerPartMaster.FM_PartCode__c) : '+ stockMap.get(dealerPartMaster.FM_PartCode__c).ExternalKey__c);
                    }else {
                        dealerPartMaster.DealerStock__c = null;
                    }
                }

                if(String.isNotBlank(dealerPartMaster.FM_DealerCode__c) && dealerPartOrderQuantityMap.containsKey(dealerPartMaster.FM_DealerCode__c)) {
                    Map<String, Decimal> partOrderQuantityMap = dealerPartOrderQuantityMap.get(dealerPartMaster.FM_DealerCode__c);
                    
                    if(String.isNotBlank(dealerPartMaster.FM_PartCode__c) && partOrderQuantityMap.containsKey(dealerPartMaster.FM_PartCode__c))
                        dueIn = partOrderQuantityMap.get(dealerPartMaster.FM_PartCode__c);

                    System.debug('dueIN : ' + dueIn);
                    // if(dealerPartMaster.DueIn__c != null && dealerPartMaster.DueIn__c > 0) dealerPartMaster.IsPOListReview__c = true;
                }

                if(dueIn == null) dueIn = 0;


                if(dealerPartMaster.MRPType__c =='VB') {
                    //Reorder Point Planning 재주문점 계획.
                    if((availableQty + dueIn - dueOut) < dealerPartMaster.ReorderPoint__c) {
                        // 1. (가용재고 + DueIn - DueOut) < ROP 이면 PO Qty = Max Lv. - (가용재고 + DueIn - DueOut)	
                        poQty = dealerPartMaster.MaximumStock__c - (availableQty + dueIn - dueOut);
                    } else {
                        //2.  Min Lot 반영	
                        poQty = dealerPartMaster.MinimumLotSize__c;
                    }
                    //PO Qty < Min Lot 이면 PO Qty = Min Lot
                    if(poQty < dealerPartMaster.MinimumLotSize__c) {
                        poQty = dealerPartMaster.MinimumLotSize__c;
                    }
                    //3. Round Value 반영 Ex.) PO Qty 가 4 R-Val 이 3 일 경우 PO Qty = 6 
                    if(poQty > dealerPartMaster.RoundingValue__c) {
                        // 4 / 3 =
                        poQty = dealerPartMaster.RoundingValue__c < 1 ? 0 : Math.ceil((Decimal)poQty / dealerPartMaster.RoundingValue__c) * dealerPartMaster.RoundingValue__c; // 3,6,90
                    } else {
                        poQty = dealerPartMaster.RoundingValue__c;
                    }
                }else if(dealerPartMaster.MRPType__c == 'ND' ) {
                    //No Planning - 계획 없음

                    //1. PO Qty = DueOut - 가용재고 - DueIn ( PO Qty < 0 이면 PO Qty = 0)
                    poQty = dueOut - availableQty - dueIn;
                    if(poQty == null || poQty < 0) poQty = 0;

                    //2. ABC 등급이 'M', 'P', 'S', 'Z' 가 아닐 경우 Min Lot 반영, Round Value 반영
                    switch on dealerPartMaster.ABCIndicator__c {
                        when 'M', 'P', 'S', 'Z' {
                            System.debug('M,P,S,Z 등급');
                        }
                        when else {
                            System.debug('M,P,S,Z 등급 외');
                            //2-1. Min Lot 반영
                            if(poQty < dealerPartMaster.MinimumLotSize__c) {
                                poQty = dealerPartMaster.MinimumLotSize__c;
                            }

                            //2-2. Round Value 반영
                            if(poQty > dealerPartMaster.RoundingValue__c) {
                                // 4 / 3 =
                                poQty = dealerPartMaster.RoundingValue__c < 1 ? 0 : Math.ceil((Decimal)poQty / dealerPartMaster.RoundingValue__c) * dealerPartMaster.RoundingValue__c; // 3,6,90
                            } else {
                                poQty = dealerPartMaster.RoundingValue__c;
                            }
                        }
                    }
                    System.debug('poQty : ' + poQty);
                }
                
                //3. PO Qty = 0 이고 Material = Last Parts 이고 대체이전품과의 관계가 'I'(단방향) 일 경우	
                if(poQTY == 0) {
                    if(isLastpart) {
                        //추후 수정이 필요함
                        // 대체 이전품의 Dueout, Duein, 가용재고를 제외한 본인 품번만의 수량으로 계산	
                        // PO Qty = DueOut - 가용재고 - DueIn ( PO Qty < 0 이면 PO Qty = 0)	
                        poQTY = dueOut- availableQTY - dueIn;
                        poQTY = poQTY < 0 ? 0 : poQTY;
                    }
                }

                dealerPartMaster.POQuantity__c = poQty;

                if(poQty > 0) dealerPartMaster.IsPOListReview__c = true; 
                else dealerPartMaster.IsPOListReview__c = false;

                if(dealerPartMaster.DealerStock__c == null) dealerPartMaster.IsPOListReview__c = false;
            }

            if(scope.size() > 0) update scope;
        } catch (Exception e) {
            String log = ''
                       + ' Exception : ' + e.getStackTraceString()
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_DealerPOReviewBatch', 'execute', 'BatchApex', log);
        }

        if(logger.size() > 0)
            logger.insertLog();
        
    }

    /*
    * @ Method : calculateQuantityByInventroyMove
    * @ Description : Type에 따른 수량 반영
    */
    private Decimal calculateQuantityByInventroyMove(String type, Decimal orderQuantity, Decimal inventoryQuantity) {
        switch on type {
            when 'S' {
                //입고
                orderQuantity -= inventoryQuantity;
            }
            when 'H' {
                //입고취소
                orderQuantity += inventoryQuantity;
            }
        }
        System.debug(' type : ' + type + ' | quantity : '+orderQuantity);
        return orderQuantity;
    }

    /*
    * @ Method : finish
    * @ Description : 배치 종료
    */
    public void finish(Database.BatchableContext context){
        System.debug(' =============== DN_DealerPOReviewBatch Batch finish ================');
        System.debug('배치 실행 완료');
        if(agencyCodes.size() > 0) {
            if(!Test.isRunningTest()) {
                Database.executeBatch(new DN_DealerPOReviewBatch(plantCode, agencyCodes), batchSize);
            }
        }
        
    }


    /**
     * 
     * Schedule 등록 코드
     * 
     * DN_DealerPOReviewBatch poScheduler = new DN_DealerPOReviewBatch('1846');
     * String cronExp = '0 0 0/3 * * ?';
     * String jobID = System.schedule('3-Hour Interval PO Review Batch', cronExp, poScheduler);
     * 
     * DN_DealerPOReviewBatch poScheduler = new DN_DealerPOReviewBatch('1846');
     * String cronExp = '0 0 06,15 * * ?';
     * String jobID = System.schedule('Twice Interval PO Review Batch', cronExp, poScheduler);
     * 
     */
    public void execute(SchedulableContext SC) {
        System.debug('Schedule plantCode : ' + plantCode);
        List<String> dealerCodes = new List<String>();
        for(DealerPortalAgecncySetting__mdt agencySetting : DealerPortalAgecncySetting__mdt.getAll().values()) {
            if(agencySetting.IsActive__c) {
                String dealerCode = agencySetting.DeveloperName.replace('A','');
                dealerCodes.add(dealerCode);
            }
        }
        if(!Test.isRunningTest()) Database.executeBatch(new DN_DealerPOReviewBatch(plantCode, dealerCodes), batchSize);
        
    }
    
}