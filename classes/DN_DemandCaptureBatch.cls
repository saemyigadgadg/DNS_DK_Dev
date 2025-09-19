/** 
 * @Class :  DN_DemandCaptureBatch
 * 
 * @Test: DN_DemandCaptureBatch_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 01. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-01 | Hyunwook Jin   | 최초작성 | 대리점 무상불출 건, 대리점 주문서 집계(DealerOrderSummary__c)
 */ 
public with sharing class DN_DemandCaptureBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {
    
    public enum OrderType {
        DEALERORDER, DEALERFREEDISPATCH
    }

    private OrderType type { 
        get {
            if(type == null) type = OrderType.DEALERORDER;
            return type;
        }
        
        set;
    }
    private String plantCode {
        get {
            if(String.isBlank(plantCode)) plantCode = '1846';
            return plantCode;
        } 
        set;
    }
    private Integer totalSize = 0;

    private DN_AsyncApexErrorLogger logger {
        get {
            if(logger == null) logger = new DN_AsyncApexErrorLogger();
            return logger;
        }
        set;
    }
    private Set<String> deleteExternalKeys {
        get {
            if(deleteExternalKeys == null) deleteExternalKeys = new Set<String>();
            return deleteExternalKeys;
        }
        set;
    }

    private Map<String, Integer> dealerOrderIdxMap {
        get {
            if(dealerOrderIdxMap == null) {
                dealerOrderIdxMap = new Map<String,Integer>();
            }
            return dealerOrderIdxMap;
        }
        set;
    }

    private Date startDate {get; set;}
    private Date endDate   {get; set;}
    private Boolean isManual {
        get {
            return (startDate != null && endDate != null);
        }
    }
    
    /*
    * @ 생성자 : DN_DemandCaptureBatch
    * @ Description : OrderType 설정
    */
    public DN_DemandCaptureBatch() {}
    public DN_DemandCaptureBatch(OrderType type) {
        this.type = type;
    }

    /*
    * @ 생성자 : DN_DemandCaptureBatch
    * @ Description : OrderType,plantCode 설정
    */
    public DN_DemandCaptureBatch(OrderType type, String plantCode) {
        this.type = type;
        this.plantCode = plantCode;
    }

    /*
    * @ 생성자 : DN_DemandCaptureBatch
    * @ Description : OrderType,startDate,endDate 설정
    */
    public DN_DemandCaptureBatch(OrderType type, String plantCode, Date startDate, Date endDate) {
        this(type, plantCode);
        this.startDate = startDate;
        this.endDate = endDate;
    }

    /*
    * @ Method : getQuery
    * @ Description : 쿼리 반환
    */
    private String getQuery() {
        String query = ' SELECT ';
        switch on type {
            when DEALERORDER {
                query += 'Id,'
                      + 'SalesOrganization__c,'
                      + 'DistributionChannel__c,'
                      + 'Division__c,'
                      + 'Dealer__c,'
                      + 'Dealer__r.CustomerCode__c,'
                      + 'OrderNumber__c,'
                      + 'OrderType__c, '
                      + 'RoadAddr__c,'
                      + 'DetailInfo__c,'
                      + 'Address__Street__s,'
                      + 'Address__PostalCode__s,'
                      + 'Address__CountryCode__s,'
                      + 'Customer__r.CustomerCode__c,'
                      + 'CustomerCode__c,'
                      + 'CustomerShipToCode__c,'
                      + 'FM_CustomerCode__c ,'
                      + 'FM_CustomerName__c,'
                      + 'Status__c,'
                      + 'CreatedDate,'
                      + 'CurrencyIsoCode,'
                      +' ( SELECT '
                      +' Id '
                      +' , Order__c '
                      +' , OrderItemNumber__c '
                      +' , Part__c '
                      +' , Part__r.Name '
                      +' , Part__r.ProductCode '
                      +' , Part__r.FM_MaterialDetails__c '
                      +' , ReplacingPart__c '
                      +' , ReplacingPart__r.Name '
                      +' , ReplacingPart__r.ProductCode '
                      +' , ReplacingPart__r.FM_MaterialDetails__c '
                      +' , Quantity__c '
                      +' , FM_Unit__c '
                      +' , CurrencyIsoCode '
                      +' , Delete__c '
                      +' FROM item__r WHERE Id != null ) '
                      +' FROM DealerOrder__c ' + getWhereClause();
            }
            when DEALERFREEDISPATCH {
                query += 'Id,'
                      + ' CreatedDate, '
                      + ' OrderItem__c, '
                      + ' OrderItem__r.Product__c, '
                      + ' OrderItem__r.Product__r.ProductCode, '
                      + ' OrderItem__r.Quantity__c,  '
                      + ' OrderItem__r.WorkOrder.Account.CustomerCode__c,  '
                      + ' OrderItem__r.WorkOrder.Account.ShippingStreet, '
                      + ' OrderItem__r.WorkOrder.Account.ShippingPostalCode, '
                      + ' OrderItem__r.WorkOrder.Account.ShippingAddress, '
                      + ' OrderItem__r.WorkOrder.Account.DetailAddress__c, '
                      + ' OrderItem__r.WorkOrder.Account.CountryLookup__r.CountryCode__c, '
                      + ' OrderItem__r.ShipTo__c, '
                      + ' Status__c, '
                      + ' FM_OrderItemNumber__c, '
                      + ' FM_OrderNumber__c, '
                      + ' Delete__c,'
                      + ' Dealer__r.CustomerCode__c, '
                      + ' Dealer__c '
                      + ' FROM DealerFreeDispatch__c '+ getWhereClause();
                query += ' AND OrderItem__c != null AND Delete__c != \'Y\' ';
            }
        }
        query += ' AND Dealer__c != null ORDER BY CreatedDate, Dealer__c ';
        return query;
    }

    /*
    * @ Method : getWhereClause
    * @ Description : 조건절 반환
    */
    private String getWhereClause() {
        String whereClause;
        if(startDate != null && endDate != null) {
            switch on type {
                when DEALERORDER {
                    whereClause = ' WHERE ( FM_OrderDate__c >= :startDate AND FM_OrderDate__c <= :endDate ) ';        
                }
                when DEALERFREEDISPATCH {
                    whereClause = ' WHERE ( FM_ApprovalDate__c >= :startDate AND FM_ApprovalDate__c <= :endDate ) ';        
                }
            }
        }else {
            whereClause = ' WHERE IsDemandCapture__c = true ';
        }

        return whereClause;
    }

    public Database.QueryLocator start(Database.BatchableContext context){
        System.debug(' =============== DN_DemandCaptureBatch Batch start ================');
        return Database.getQueryLocator(getQuery());
    }

    /*
    * @ Method : execute
    * @ Description : MPPS 데이터 업데이트
    */
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== DN_DemandCaptureBatch Batch Execute ================');
        totalSize += scope.size();
        List<DealerOrderSummary__c> upsertList = new List<DealerOrderSummary__c>();
        try {
            switch on type {
                when DEALERORDER {
                    upsertList.addAll(convertFrom((List<DealerOrder__c>)scope));
                }
                when DEALERFREEDISPATCH {
                    upsertList.addAll(convertFrom((List<DealerFreeDispatch__c>)scope));
                }
            }


            if(upsertList.size() > 0) {
                //Region 이 공백일 경우 
                //1. Post Code(앞2자리) 를 이용하여 Region 조회 (ZSPT2380 - ZipRegionAreaByMPPS__c) > Region 대신 Area 
                //2. 해당 대리점의 Region 중 하나를 입력 (ZSPT2400 - DealerAreaByMPPS__c, ZSPT2410 - RegionAreaByMPPS__c) 
                Set<String> regionCodeSet = new Set<String>();
                Set<String> dealerCodeSet = new Set<String>();
                for(DealerOrderSummary__c summary : upsertList) {  
                    regionCodeSet.add(summary.Address__PostalCode__s?.left(2));
                    if(String.isNotBlank(summary.DealerCode__c)) dealerCodeSet.add(summary.DealerCode__c);
                }
                regionCodeSet.remove(null);
    
                Map<String, ZipRegionAreaByMPPS__c> zipRegionMap = new Map<String, ZipRegionAreaByMPPS__c>();
                for(ZipRegionAreaByMPPS__c zipRegion :[
                    SELECT ZipCode__c, Region__c, Region__r.Area__r.Name, Region__r.Area__r.Area__c
                    FROM ZipRegionAreaByMPPS__c
                    WHERE ZipCode__c IN : regionCodeSet
                ]) {
                    zipRegionMap.put(zipRegion.ZipCode__c, zipRegion);
                }

                Map<String, DealerAreaByMPPS__c> dealerAreaMap = new Map<String, DealerAreaByMPPS__c>();
                for(DealerAreaByMPPS__c dealerArea : [
                    SELECT
                        Dealer__c, Area__c, DealerCode__c, AreaCode__c, FM_AreaCode__c, FM_DealerCode__c
                    FROM DealerAreaByMPPS__c
                    WHERE FM_DealerCode__c IN :dealerCodeSet
                ]) {
                    dealerAreaMap.put(dealerArea.FM_DealerCode__c, dealerArea);
                }
    
                            
                for(DealerOrderSummary__c summary : upsertList) {  
                    String zipCode = summary.Address__PostalCode__s?.left(2);
                    if(zipRegionMap.containsKey(zipCode)) {
                        summary.Area__c = zipRegionMap.get(zipCode).Region__r.Area__c;
                        // summary.AreaCode__c = zipRegionMap.get(zipCode).Region__r.Area__r.Area__c;
                    }
                    
                    if(summary.AreaCode__c == null || summary.Area__c == null) {
                        if(dealerAreaMap.containsKey(summary.DealerCode__c)) {
                            summary.Area__c = dealerAreaMap.get(summary.DealerCode__c).Area__c;
                            // summary.AreaCode__c = dealerAreaMap.get(summary.DealerCode__c).FM_AreaCode__c;
                        }
                    }

                    
                }
    
                Schema.SObjectType objectType = upsertList.getSObjectType();
                String objectApi = objectType.getDescribe().getName();
                Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
                Schema.SObjectField fieldToken = fieldMap.get('externalkey__c');

                // upsert upsertList ExternalKey__c;
                // List<SObject> updateList = new List<SObject>();
                Map<Integer, SObject> updateMap = new Map<Integer, SObject>();
                Integer idx = 0;
                List<Database.UpsertResult> upsertResultList = Database.upsert(upsertList, fieldToken, false);
                for (Database.UpsertResult ur : upsertResultList) {
                    if (ur.isSuccess()) {
                        System.debug('Successfully upsert  ID: ' + ur.getId());
                        
                        switch on type {
                            when DEALERORDER {
                                String key = upsertList.get(idx).ExternalKey__c;
                                Integer mappingIdx = dealerOrderIdxMap.get(key);

                                if(!updateMap.containsKey(mappingIdx)) {
                                    updateMap.put(mappingIdx, scope[mappingIdx]);
                                }
                            }
                            when DEALERFREEDISPATCH {
                                String key = upsertList.get(idx).ExternalKey__c;
                                // updateList.add(scope[idx]);
                                updateMap.put(idx, scope[idx]);
                            }
                        }
                    }
                    else {
                        for(Database.Error err : ur.getErrors()) {
                            String log = 'The following error has occurred. upsert IDX ['+idx +'] \n'
                                    + err.getStatusCode() + ': ' + err.getMessage() + ' \n '
                                    + ' fields that affected this error: ' + err.getFields();
                            System.debug(log);                    
                            
                            logger.addLog(context.getJobId() , 'DN_DemandCaptureBatch', 'execute', 'BatchApex', log);
                        }
                    }
                    idx++;
                }

                if(updateMap.size() > 0) {
                    update updateMap.values();
                }
            }  

            System.debug(' deleteExternalKeys: ');
            System.debug(JSON.serialize(deleteExternalKeys));

            if(deleteExternalKeys.size() > 0) {
                delete [SELECT Id FROM DealerOrderSummary__c WHERE ExternalKey__c IN :deleteExternalKeys];
                deleteExternalKeys.clear();
            }
        } catch (Exception e) {
            String log = ' query : ' +getQuery() + '\n'
                       + ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_DemandCaptureBatch', 'execute', 'BatchApex', log);
        }

        if(logger.size() > 0) {
            String log = ' query : ' +getQuery() + '\n';
            logger.addLog(context.getJobId() , 'DN_DemandCaptureBatch', 'execute', 'BatchApex', log);
        }

    }

    /*
    * @ Method : convertFrom
    * @ Description : 대리점 주문건
    */
    private List<DealerOrderSummary__c> convertFrom(List<DealerOrder__c> Orders) {
        List<DealerOrderSummary__c> demandCaptureList = new List<DealerOrderSummary__c>();
        Integer idx = 0;
        for(DealerOrder__c order : Orders) {
            demandCaptureList.addAll(convertFrom(order, idx));
            order.IsDemandCapture__c = false;
            idx++;
        }
        return demandCaptureList;
    }

    /*
    * @ Method : convertFrom
    * @ Description : 대리점 주문건
    */
    private List<DealerOrderSummary__c> convertFrom(DealerOrder__c Order, Integer idx) {
        List<DealerOrderSummary__c> demandCaptureList = new List<DealerOrderSummary__c>();
        String orderNumber = Order.OrderNumber__c;
        for(DealerOrderItem__c item : Order.item__r) {
            String externalKey = orderNumber + '_' + item.OrderItemNumber__c;
            dealerOrderIdxMap.put(externalKey, idx);
            DealerOrderSummary__c demandCapture = new DealerOrderSummary__c(
                ExternalKey__c          = externalKey,
                DealerOrderItem__c      = item.Id,
                DemandType__c           = 'DS',
                SalesOrganization__c    = Order.SalesOrganization__c,
                DistributionChannel__c  = Order.DistributionChannel__c,
                Division__c             = Order.Division__c,
                Plant__c                = Order.SalesOrganization__c,
                OrderType__c            = Order.OrderType__c,
                Part__c                 = item.ReplacingPart__c,
                OrderQuantity__c        = item.Quantity__c,
                CurrentQuantity__c      = item.Quantity__c,
                SoldToCode__c           = Order.FM_CustomerCode__c,
                ShipToCode__c           = Order.FM_CustomerCode__c,
                Dealer__c               = Order.Dealer__c,
                RoadAddr__c             = Order.RoadAddr__c,
                DetailInfo__c           = Order.DetailInfo__c,
                Address__Street__s      = Order.Address__Street__s,
                Address__PostalCode__s  = Order.Address__PostalCode__s,
                Address__CountryCode__s = Order.Address__CountryCode__s,
                OrderNumber__c = Order.OrderNumber__c,
                OrderItemNumber__c = item.OrderItemNumber__c,
                PartCode__c = item.ReplacingPart__r.ProductCode,
                DealerCode__c = Order.Dealer__r.CustomerCode__c,
                CreatedDateTime__c = Order.CreatedDate
            );

            if('Y'.equals(item.Delete__c)) {
                deleteExternalKeys.add(externalKey);
                // demandCapture.OrderQuantity__c = demandCapture.CurrentQuantity__c = 0;
            }else {
                if(demandCapture.ExternalKey__c != null)
                    demandCaptureList.add(demandCapture);
            }
            
            if(String.isBlank(demandCapture.SoldToCode__c)) 
                demandCapture.SoldToCode__c = demandCapture.ShipToCode__c = Order.CustomerCode__c;            
        }

        return demandCaptureList;
    }

    /*
    * @ Method : convertFrom
    * @ Description : 대리점 무상불출 건
    */
    private List<DealerOrderSummary__c> convertFrom(List<DealerFreeDispatch__c> items) {
        List<DealerOrderSummary__c> demandCaptureList = new List<DealerOrderSummary__c>();
        Set<String> shipToWorkCenterIdList = new Set<String>();
        for(DealerFreeDispatch__c item : items) {
            shipToWorkCenterIdList.add(item.OrderItem__r.ShipTo__c);
        }

        Map<Id,ServiceTerritory> shipToWorkCenterMap = new Map<Id,ServiceTerritory>([
                SELECT Id, 
                       ServiceWorkCenter__r.Name, 
                       ServiceWorkCenter__r.CustomerCode__c,
                       ServiceWorkCenter__r.ShippingStreet, 
                       ServiceWorkCenter__r.ShippingCity, 
                       ServiceWorkCenter__r.ShippingState, 
                       ServiceWorkCenter__r.DetailAddress__c,
                       ServiceWorkCenter__r.ShippingPostalCode,
                       ServiceWorkCenter__r.CountryLookup__r.CountryCode__c,
                       ServiceWorkCenter__r.FM_Address__c
                FROM ServiceTerritory where Classify__c = 'W/C' and Id IN :shipToWorkCenterIdList
            ]);

        for(DealerFreeDispatch__c item : items) {
            //item4자리?
            String externalKey = item.FM_OrderNumber__c +'_'+ item.FM_OrderItemNumber__c;
            DealerOrderSummary__c demandCapture = new DealerOrderSummary__c(
                ExternalKey__c          = externalKey,
                ServiceOrderItem__c     = item.OrderItem__c,
                DemandType__c           = 'DF',
                SalesOrganization__c    = '1846',
                DistributionChannel__c  = '10',
                Division__c             = '40',
                Plant__c                = '1846',
                Part__c                 = item.OrderItem__r.Product__c,
                OrderQuantity__c        = item.OrderItem__r.Quantity__c,
                CurrentQuantity__c      = item.OrderItem__r.Quantity__c,
                SoldToCode__c           = item.OrderItem__r.WorkOrder.Account.CustomerCode__c,
                Dealer__c               = item.Dealer__c,
                OrderNumber__c = item.FM_OrderNumber__c,
                OrderItemNumber__c = item.FM_OrderItemNumber__c,
                PartCode__c = item.OrderItem__r.Product__r.ProductCode,
                DealerCode__c = item.Dealer__r.CustomerCode__c,
                // AreaCode__c = Order.,
                CreatedDateTime__c      = item.CreatedDate
            );

            if('3'.equals(item.Status__c)) {
                deleteExternalKeys.add(externalKey);
                // demandCapture.OrderQuantity__c = demandCapture.CurrentQuantity__c = 0;
            }else {
                if(demandCapture.ExternalKey__c != null)
                    demandCaptureList.add(demandCapture);
            }

            try {
                //Id 외에 값도 들어감
                Id serviceTerrorityId = Id.valueOf(item.OrderItem__r.ShipTo__c);
                if(shipToWorkCenterMap.containsKey(serviceTerrorityId)) {
                    ServiceTerritory shipToWorkCenter = shipToWorkCenterMap.get(serviceTerrorityId);
                    demandCapture.ShipToCode__c           = shipToWorkCenter.ServiceWorkCenter__r.CustomerCode__c;
                    demandCapture.DetailInfo__c           = shipToWorkCenter.ServiceWorkCenter__r.DetailAddress__c;
                    demandCapture.Address__Street__s      = shipToWorkCenter.ServiceWorkCenter__r.ShippingStreet;
                    demandCapture.RoadAddr__c             = (String.isBlank(demandCapture.DetailInfo__c)) ? demandCapture.Address__Street__s : demandCapture.Address__Street__s.replace(demandCapture.DetailInfo__c, '');
                    demandCapture.Address__PostalCode__s  = shipToWorkCenter.ServiceWorkCenter__r.ShippingPostalCode;
                    demandCapture.Address__CountryCode__s = shipToWorkCenter.ServiceWorkCenter__r.CountryLookup__r.CountryCode__c;
                }   

            } catch (Exception e) {
                System.debug(e.getMessage());

                demandCapture.ShipToCode__c           = item.OrderItem__r.WorkOrder.Account.CustomerCode__c;
                demandCapture.DetailInfo__c           = item.OrderItem__r.WorkOrder.Account.DetailAddress__c;
                demandCapture.Address__Street__s      = item.OrderItem__r.WorkOrder.Account.ShippingStreet;
                demandCapture.RoadAddr__c             = (String.isBlank(demandCapture.DetailInfo__c)) ? demandCapture.Address__Street__s : demandCapture.Address__Street__s.replace(demandCapture.DetailInfo__c, '');
                demandCapture.Address__PostalCode__s  = item.OrderItem__r.WorkOrder.Account.ShippingPostalCode;
                demandCapture.Address__CountryCode__s = item.OrderItem__r.WorkOrder.Account.CountryLookup__r.CountryCode__c;
            }


            item.IsDemandCapture__c = false;
            
        }

        return demandCaptureList;
    }

    /*
    * @ Method : finish
    * @ Description : 배치 실행 완료 후 후속 배치 실행
    */
    public void finish(Database.BatchableContext context){
        System.debug(' =============== DN_DemandCaptureBatch Batch finish ================');
        System.debug('배치 실행 완료');

        try {

            //코드 Script로 특정 날짜만 돌릴 경우 한 가지 유형 Capture
            System.debug('isManual : '+isManual);
            if(isManual) {
                return;
            } else {
                // 대리점 주문서일 경우 대리점 무상불출 Batch 실행
                if(!Test.isRunningTest()) {
                    if(type.equals(OrderType.DEALERORDER)) {
                        Database.executeBatch(new DN_DemandCaptureBatch(OrderType.DEALERFREEDISPATCH, plantCode));    
                    }else if(type.equals(OrderType.DEALERFREEDISPATCH)) {
                        Database.executeBatch(new DN_MonthlyDemandSummaryBatch(DN_MonthlyDemandSummaryBatch.SummaryType.DEALER, plantCode), 50);

                        System.scheduleBatch(new DN_MonthlyDemandSummaryBatch(DN_MonthlyDemandSummaryBatch.SummaryType.REGION, plantCode), 'MonthlyDemandSummaryBatchRegion' , 30, 50);
                    }
                }
            }

        } catch (Exception e) {
            String log = ''
                       + ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_DemandCaptureBatch', 'finish', 'BatchApex', log);
        } finally {
            logger.insertLog();
        }   
    }

    /**
     * 
     * Schedule 등록 코드
     * 
     * DN_DemandCaptureBatch captureScheduler = new DN_DemandCaptureBatch('1846');
     * String cronExp = '0 0 23 * * ?';
     * String jobID = System.schedule('MPPS DemandCapture', cronExp, captureScheduler);
     * 
     */
     public void execute(SchedulableContext SC) {
        System.debug('Schedule plantCode : ' + plantCode);
        Database.executeBatch(this);
    }

    public class CustomException extends Exception {}
}