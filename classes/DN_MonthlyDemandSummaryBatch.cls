/** 
 * @Class :  DN_MonthlyDemandSummaryBatch
 * 
 * @Test: 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 02. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-02 | Hyunwook Jin   | 최초작성 (월별 대리점별 집계, 월별 지역별 집계)
 */ 
public with sharing class DN_MonthlyDemandSummaryBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
    public enum SummaryType {
        DEALER, REGION
    }

    /*
    * @ Description : 현재 유저 정보
    */
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    private DN_AsyncApexErrorLogger logger {
        get {
            if(logger == null) logger = new DN_AsyncApexErrorLogger();
            return logger;
        }
        set;
    }

    private String dealerId {get; set;} //DealerId
    private Integer beforeNMonth {
        get {
            if(beforeNMonth == null) beforeNMonth = 0;
            return beforeNMonth;
        }
        set;
    }
    private SummaryType type {get; set;}
    private String plantCode {
        get {
            if(String.isBlank(plantCode)) plantCode = '1846';
            return plantCode;
        } 
        set;
    }

    private Map<String,MonthlyDemandSummaryByDealer__c> monthlySummaryDealerMap {
        get {
            if(monthlySummaryDealerMap == null) monthlySummaryDealerMap = new Map<String,MonthlyDemandSummaryByDealer__c>();
            return monthlySummaryDealerMap;
        }
        set;
    }

    private Map<String,MonthlyDemandSummaryByRegion__c> monthlySummaryRegionMap {
        get {
            if(monthlySummaryRegionMap == null) monthlySummaryRegionMap = new Map<String,MonthlyDemandSummaryByRegion__c>();
            return monthlySummaryRegionMap;
        }
        set;
    }

    private Map<String,Decimal> partIdQuantityMap {
        get {
            if(partIdQuantityMap == null) partIdQuantityMap = new Map<String, Decimal>();
            return partIdQuantityMap;
        }
        set;
    }
    private Map<String,Decimal> partIdFrequencyMap {
        get {
            if(partIdFrequencyMap == null) partIdFrequencyMap = new Map<String, Decimal>();
            return partIdFrequencyMap;
        }
        set;
    }
    private Map<String,String> replacingInfoMap { //Key: LastPartId, value: PartId
        get {
            if(replacingInfoMap == null) replacingInfoMap = new Map<String, String>();
            return replacingInfoMap;
        }
        set;
    }
    
    /*
    * @ 생성자 : DN_MonthlyDemandSummaryBatch
    * @ Description : type 설정
    */
    public DN_MonthlyDemandSummaryBatch(SummaryType type) {
        this.type = type;
    }

    /*
    * @ 생성자 : DN_MonthlyDemandSummaryBatch
    * @ Description : type,plantCode 설정
    */
    public DN_MonthlyDemandSummaryBatch(SummaryType type, String plantCode) {
        this.type = type;
        this.plantCode = plantCode;
    }

    /*
    * @ 생성자 : DN_MonthlyDemandSummaryBatch
    * @ Description : type,plantCode 설정
    */
    public DN_MonthlyDemandSummaryBatch(SummaryType type, String dealerId, Integer beforeNMonth) {
        this(dealerId, beforeNMonth);
        this.type = type;
    }

    /*
    * @ 생성자 : DN_MonthlyDemandSummaryBatch
    * @ Description : dealerId,beforeNMonth 설정
    */
    public DN_MonthlyDemandSummaryBatch(String dealerId, Integer beforeNMonth) {
        this(beforeNMonth);
        this.dealerId = dealerId;
    }

    /*
    * @ 생성자 : DN_MonthlyDemandSummaryBatch
    * @ Description : beforeNMonth 설정
    */
    public DN_MonthlyDemandSummaryBatch(Integer beforeNMonth) {
        this.beforeNMonth = beforeNMonth;
    }

    /*
    * @ Method : start
    * @ Description : 배치 시작
    */
    public Database.QueryLocator start(Database.BatchableContext context){
        System.debug(' =============== DN_MonthlyDemandSummaryBatch Batch start ================');
        return Database.getQueryLocator(getQuery());
    }

    /*
    * @ Method : getQuery
    * @ Description : 쿼리 반환
    */
    private String getQuery() {
        String query = ' SELECT '
                     + ' Id, '
                     + ' FM_OrderNumber__c, '
                     + ' FM_OrderItemNumber__c,'
                     + ' DemandType__c,'
                     + ' OrderType__c, '
                     + ' SalesOrganization__c, '
                     + ' DistributionChannel__c, '
                     + ' Division__c, '
                     + ' Plant__c, '
                     + ' Part__c, '
                     + ' Part__r.ProductCode, '
                     + ' OrderQuantity__c, '
                     + ' CurrentQuantity__c, '
                     + ' FM_Unit__c, '
                     + ' SoldToCode__c, '
                     + ' ShipToCode__c, '
                     + ' Dealer__c, '
                     + ' Dealer__r.CustomerCode__c, '
                     + ' RoadAddr__c, '
                     + ' DetailInfo__c, '
                     + ' Address__Street__s, '
                     + ' Address__City__s, '
                     + ' Address__PostalCode__s, '
                     + ' Address__StateCode__s, '
                     + ' Address__CountryCode__s, '
                     + ' Address__Latitude__s, '
                     + ' Address__Longitude__s, '
                     + ' Address__GeocodeAccuracy__s, '
                     + ' Area__c, '
                     + ' Area__r.Area__c, '
                     + ' FM_DealerCode__c, '
                     + ' FM_AreaCode__c, '
                     + ' FM_PartCode__c, '
                     + ' DealerOrderItem__c, '
                     + ' ServiceOrderItem__c, '
                     + ' CreatedDateTime__c'
                     + ' FROM DealerOrderSummary__c '
                     + ' WHERE Id != null AND Plant__c = :plantCode AND Part__c != null ';
        
        if(String.isNotBlank(dealerId))
            query += ' AND Dealer__c = \''+dealerId+'\'';

        //이번달
        if(beforeNMonth == 0) {
            query += ' AND CreatedDateTime__c = THIS_MONTH ';
        }else {
            //N개월 전달
            query += ' AND CreatedDateTime__c = LAST_N_MONTHS:'+beforeNMonth
                   + ' AND CreatedDateTime__c < LAST_N_MONTHS:'+(beforeNMonth-1);

                   
                // Date startDateKST = Date.today().addMonths(-1 * beforeNMonth).toStartOfMonth();
                // Date endDateKST = startDateKST.addMonths(1);
                
                // Datetime startUTC = Datetime.newInstance(startDateKST, Time.newInstance(0, 0, 0, 0));
                // System.debug(startUTC);
                // Datetime endUTC = Datetime.newInstance(endDateKST, Time.newInstance(0, 0, 0, 0));
                // System.debug('startUTC: '+ startUTC.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                // System.debug('endUTC: '+ endUTC.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                   
                //    query += ' AND CreatedDateTime__c >= ' + startUTC.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                //    query += ' AND CreatedDateTime__c < ' + endUTC.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }

        query += ' ORDER BY Dealer__c, Part__c, SalesOrganization__c, DistributionChannel__c, Division__c ';
            //   + ' LIMIT 50000000 ';

        System.debug('start query ==> '+ query);
        return query;
    }

    /*
    * @ Method : execute
    * @ Description : 배치 실행
    */
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== DN_MonthlyDemandSummaryBatch Batch Execute ================');
        System.debug('type : ' +type);
        List<DealerOrderSummary__c> demandCaptureList = (List<DealerOrderSummary__c>)scope;
        try {

            switch on type {
                when DEALER {
                    setConvertFromDealer(demandCaptureList);        
                }
                when REGION {
                    setConvertFromRegion(demandCaptureList);
                }
                
            }

            
        } catch (Exception e) {
            String log = type.name()+' query : ' +getQuery() + '\n'
                       + ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_MonthlyDemandSummaryBatch', 'execute', 'BatchApex', log);
        }
    }

    /*
    * @ Method : getCustomerPriceByIf
    * @ Description : 부품별 가격 정보 조회
    */
    private Map<String, Decimal> getCustomerPriceByIf(String dealerCode, String salesOrganization, String distributionChannel, String division, String countryCode, Set<String> partCodeSet) {
        Map<String, Decimal> priceMap = new Map<String, Decimal>();

        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req req = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req();
        req.I_LANGU = 'ko'; 
        List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL> D_DETAIL_List = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>();
        
        for(String partCode : partCodeSet) {
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
            D_DETAIL.MATNR = partCode;
            D_DETAIL_List.add(D_DETAIL);
        }
        req.D_DETAIL = D_DETAIL_List;
        
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO();
        I_USERINFO.KUNNR        = dealerCode;
        I_USERINFO.VKORG        = salesOrganization;
        I_USERINFO.VTWEG        = distributionChannel;
        I_USERINFO.SPART        = division;
        I_USERINFO.LAND1        = countryCode;
        I_USERINFO.DF_CHK       = 'X';
        req.I_USERINFO          = I_USERINFO;

        IF_ERP_Parts_Multipart instance = new IF_ERP_Parts_Multipart();
        // instance.interfaceUtil.isInsertLog = false;
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res ifResult = instance.IF_PARTS_022(req);
        
        if('S'.equals(ifResult.O_RETURN.TYPE)) {
            for(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL partInfo : ifResult.D_DETAIL) {
                //고객판매가
                priceMap.put(partInfo.MATNR, Decimal.valueOf(partInfo.NETPR));
            }
        }

        return priceMap;
    }

    /*
    * @ Method : setConvertFromDealer
    * @ Description : MonthlyDemandSummaryByDealer__c에 데이터 매핑
    */
    private void setConvertFromDealer(List<DealerOrderSummary__c> orderItems) {
        Map<String, ProductByPlant__c> productMap = new Map<String, ProductByPlant__c>();
        
        String salesOranization;
        String distributionChannel;
        String division;
        String dealerCode;
        Set<String> partCodeSet = new Set<String>();
        Set<String> partIdSet = new Set<String>();
        for(DealerOrderSummary__c orderItem : orderItems) {
            if(orderItem.Part__c != null) partIdSet.add(orderItem.Part__c);
            partCodeSet.add(orderItem.FM_PartCode__c); // orderItem.Part__r.ProductCode > orderItem.FM_PartCode__c
            salesOranization = orderItem.SalesOrganization__c;
            distributionChannel = orderItem.DistributionChannel__c;
            division = orderItem.Division__c;
            dealerCode = orderItem.FM_DealerCode__c; // orderItem.Dealer__r.CustomerCode__c > orderItem.FM_DealerCode__c
        }

        Map<String, Decimal> priceMap = getCustomerPriceByIf(dealerCode, salesOranization, distributionChannel, division, currentUser.getCountry(), partCodeSet);

        for(ProductByPlant__c plantProduct : [
            SELECT 
                Part__c, 
                Plant__c, 
                ABCIndicator__c, 
                PlantSpecificMaterialStatus__c, 
                ReplacingPart__c, 
                StartPart__c, 
                StartPart__r.ProductCode, 
                LastPart__c, 
                LastPart__r.ProductCode, 
                RoundingValue__c, 
                MinLotSize__c, 
                MRPType__c, 
                MaximumStock__c, 
                ReorderPoint__c, 
                PlannedDeliveryDay__c, 
                MaintenanceStatus__c, 
                ServiceCode__c, 
                InterchangeabilityCode__c, 
                NotServiceReason__c, 
                SafetyStock__c
            FROM ProductByPlant__c
            WHERE Plant__c = :plantCode AND Part__c IN :partIdSet
        ]) {
            productMap.put(plantProduct.Part__c , plantProduct);
        }

        for(DealerOrderSummary__c orderItem : orderItems) {
            String yearMonth = getYearMonthFrom(orderItem.CreatedDateTime__c);
            String dealerKey = orderItem.SalesOrganization__c + '_' +orderItem.DistributionChannel__c+'_'+orderItem.Division__c+'_'
                       +yearMonth+'_'+orderItem.FM_DealerCode__c+'_'+orderItem.FM_PartCode__c;//판매조직정보(조직_유통채널_제품)_년월_DealerCode_PartCode
        
            //Dealer
            if(monthlySummaryDealerMap.containsKey(dealerKey)) {
                MonthlyDemandSummaryByDealer__c monthlySummaryDealer = monthlySummaryDealerMap.get(dealerKey);
                monthlySummaryDealer.Frequency__c += 1;
                monthlySummaryDealer.Quantity__c += orderItem.CurrentQuantity__c;
                includeDemandForLastPart(monthlySummaryDealer, orderItem.CurrentQuantity__c, 1);

            }else {

                MonthlyDemandSummaryByDealer__c monthlySummaryDealer = new MonthlyDemandSummaryByDealer__c(
                    ExternalKey__c = dealerKey,
                    AnalysisPeriodMonth__c = yearMonth,
                    // DemandType__c = orderItem.DemandType__c,
                    Dealer__c = orderItem.Dealer__c,
                    Part__c = orderItem.Part__c,
                    Plant__c = orderItem.Plant__c,
                    Quantity__c = orderItem.CurrentQuantity__c,
                    PartCode__c = orderItem.FM_PartCode__c,
                    DealerCode__c = orderItem.FM_DealerCode__c,
                    Frequency__c = 1,
                    ReplacementQuantitiy__c = 0,
                    ReplacementFrequency__c = 0,
                    Replace__c = 'X'
                );

                if(priceMap.containsKey(orderItem.FM_PartCode__c))
                    monthlySummaryDealer.CustomerPrice__c = priceMap.get(orderItem.FM_PartCode__c);

                if(productMap.containsKey(monthlySummaryDealer.Part__c)) {
                    ProductByPlant__c product = productMap.get(monthlySummaryDealer.Part__c);
                    monthlySummaryDealer.StartPart__c = product.StartPart__c;
                    monthlySummaryDealer.LastPart__c = product.LastPart__c;
                    monthlySummaryDealer.StartPartCode__c = product.StartPart__r.ProductCode;
                    monthlySummaryDealer.LastPartCode__c = product.LastPart__r.ProductCode;
                    monthlySummaryDealer.MRPType__c = product.MRPType__c;
                }

                includeDemandForLastPart(monthlySummaryDealer, monthlySummaryDealer.Quantity__c, monthlySummaryDealer.Frequency__c);
                monthlySummaryDealerMap.put(dealerKey, monthlySummaryDealer);
            }

        }
    }

    /*
    * @ Method : includeDemandForLastPart
    * @ Description : LastPart 매핑
    */
    private void includeDemandForLastPart(SObject monthlySummary, Decimal quantity, Decimal frequency) {
        //1.  Last Parts 는 대체 이전 품번의 모든 수요를 포함한다. 대체품이 A->B 일 때 A의 Demand를 B의 Demand에 이전한다.
        //각 대체품 및 품번 정보들 Summary

        String partId = String.valueOf(monthlySummary.get('Part__c'));
        String lastPartId = String.valueOf(monthlySummary.get('LastPart__c'));

        if(partIdQuantityMap.containsKey(partId)) {
            partIdQuantityMap.put(partId ,partIdQuantityMap.get(partId) + quantity);
        }else {
            partIdQuantityMap.put(partId, quantity);
        }

        if(partIdFrequencyMap.containsKey(partId)) {
            partIdFrequencyMap.put(partId ,partIdFrequencyMap.get(partId) + frequency);
        }else {
            partIdFrequencyMap.put(partId, frequency);
        }

        if(String.isNotBlank(lastPartId) && partId != lastPartId) {
            if(replacingInfoMap.containsKey(lastPartId)) {
                String replacingPart = replacingInfoMap.get(lastPartId);
                replacingPart += '_'+ partId;
                replacingInfoMap.put(lastPartId , replacingPart);
            }else {
                replacingInfoMap.put(lastPartId, partId);
            }
        }
    }

    /*
    * @ Method : setConvertFromRegion
    * @ Description : MonthlyDemandSummaryByRegion__c 데이터 설정
    */
    private void setConvertFromRegion(List<DealerOrderSummary__c> orderItems) {
        Map<String, ProductByPlant__c> productMap = new Map<String, ProductByPlant__c>();
    
        String salesOranization;
        String distributionChannel;
        String division;
        String dealerCode;
        Set<String> partCodeSet = new Set<String>();
        Set<String> partIdSet = new Set<String>();
        for(DealerOrderSummary__c orderItem : orderItems) {
            if(orderItem.Part__c != null) partIdSet.add(orderItem.Part__c);
            partCodeSet.add(orderItem.FM_PartCode__c); // orderItem.Part__r.ProductCode > orderItem.FM_PartCode__c
            salesOranization = orderItem.SalesOrganization__c;
            distributionChannel = orderItem.DistributionChannel__c;
            division = orderItem.Division__c;
            dealerCode = orderItem.FM_DealerCode__c;
        }

        Map<String, Decimal> priceMap = getCustomerPriceByIf(dealerCode, salesOranization, distributionChannel, division, currentUser.getCountry(), partCodeSet);

        for(ProductByPlant__c plantProduct : [
            SELECT 
                Part__c, 
                Plant__c, 
                ABCIndicator__c, 
                PlantSpecificMaterialStatus__c, 
                ReplacingPart__c, 
                StartPart__c, 
                StartPart__r.ProductCode, 
                LastPart__c, 
                LastPart__r.ProductCode, 
                RoundingValue__c, 
                MinLotSize__c, 
                MRPType__c, 
                MaximumStock__c, 
                ReorderPoint__c, 
                PlannedDeliveryDay__c, 
                MaintenanceStatus__c, 
                ServiceCode__c, 
                InterchangeabilityCode__c, 
                NotServiceReason__c, 
                SafetyStock__c
            FROM ProductByPlant__c
            WHERE Plant__c = :plantCode AND Part__c IN :partIdSet
        ]) {
            productMap.put(plantProduct.Part__c , plantProduct);
        }

        for(DealerOrderSummary__c orderItem : orderItems) {
            String yearMonth = getYearMonthFrom(orderItem.CreatedDateTime__c);
            String regionKey = orderItem.SalesOrganization__c + '_' +orderItem.DistributionChannel__c+'_'+orderItem.Division__c+'_'
                       +yearMonth+'_'+orderItem.FM_AreaCode__c+'_'+orderItem.FM_PartCode__c;//판매조직정보(조직_유통채널_제품)_년월_AreaCode_PartCode

            if(monthlySummaryRegionMap.containsKey(regionKey)) {
                MonthlyDemandSummaryByRegion__c monthlySummaryRegion = monthlySummaryRegionMap.get(regionKey);
                monthlySummaryRegion.Frequency__c += 1;
                monthlySummaryRegion.Quantity__c += orderItem.CurrentQuantity__c;
                includeDemandForLastPart(monthlySummaryRegion, orderItem.CurrentQuantity__c, 1);

            }else {
                MonthlyDemandSummaryByRegion__c monthlySummaryRegion = new MonthlyDemandSummaryByRegion__c(
                    ExternalKey__c = regionKey,
                    AnalysisPeriodMonth__c = yearMonth,
                    // DemandType__c = orderItem.DemandType__c,
                    Area__c = orderItem.Area__c,
                    Part__c = orderItem.Part__c,
                    Plant__c = orderItem.Plant__c,
                    PartCode__c = orderItem.FM_PartCode__c,
                    AreaCode__c = orderItem.FM_AreaCode__c,
                    Quantity__c = orderItem.CurrentQuantity__c,
                    Frequency__c = 1,
                    ReplacementQuantitiy__c = 0,
                    ReplacementFrequency__c = 0,
                    Replace__c = 'X'
                );

                if(priceMap.containsKey(orderItem.FM_PartCode__c))
                    monthlySummaryRegion.CustomerPrice__c = priceMap.get(orderItem.FM_PartCode__c);

                if(productMap.containsKey(monthlySummaryRegion.Part__c)) {
                    ProductByPlant__c product = productMap.get(monthlySummaryRegion.Part__c);
                    monthlySummaryRegion.StartPart__c = product.StartPart__c;
                    monthlySummaryRegion.LastPart__c = product.LastPart__c;
                    monthlySummaryRegion.StartPartCode__c = product.StartPart__r.ProductCode;
                    monthlySummaryRegion.LastPartCode__c = product.LastPart__r.ProductCode;
                    monthlySummaryRegion.MRPType__c = product.MRPType__c;
                }

                includeDemandForLastPart(monthlySummaryRegion, monthlySummaryRegion.Quantity__c, monthlySummaryRegion.Frequency__c);
                monthlySummaryRegionMap.put(regionKey, monthlySummaryRegion);
            }
        }
    }

    /*
    * @ Method : getYearMonthFrom
    * @ Description : yyyMM으로 변환
    */
    private String getYearMonthFrom(DateTime targetTime) {
        return targetTime.format('yyyyMM');
    }

    /*
    * @ Method : finish
    * @ Description : 배치 종료 후 데이터 업설트 처리 및 후속 배치 실행
    */
    public void finish(Database.BatchableContext context){
        System.debug(' =============== DN_MonthlyDemandSummaryBatch Batch finish ================');
        System.debug('배치 실행 완료');
        try {
            if(type == null) throw new CustomException('type is null');

            if(monthlySummaryDealerMap.size() > 0) {

                for(MonthlyDemandSummaryByDealer__c summaryDealer : monthlySummaryDealerMap.values()) {
                    setReplacingInfo(summaryDealer);
                }

                if(monthlySummaryDealerMap.size() < 9000)
                    upsert monthlySummaryDealerMap.values() ExternalKey__c;
                else 
                    Database.executeBatch(new DN_DMLBatchProcessing(DN_DMLBatchProcessing.DmlType.ADDORMODIFY, monthlySummaryDealerMap.values(), 'ExternalKey__c'), 5000);
            }

            if(monthlySummaryRegionMap.size() > 0) {
                for(MonthlyDemandSummaryByRegion__c summaryDealer : monthlySummaryRegionMap.values()) {
                    setReplacingInfo(summaryDealer);
                }

                if(monthlySummaryRegionMap.size() < 9000)
                    upsert monthlySummaryRegionMap.values() ExternalKey__c;
                else
                    Database.executeBatch(new DN_DMLBatchProcessing(DN_DMLBatchProcessing.DmlType.ADDORMODIFY, monthlySummaryRegionMap.values(), 'ExternalKey__c'), 5000);
            }
    
            if(beforeNMonth < 18) {
                if(!Test.isRunningTest())
                    Database.executeBatch(new DN_MonthlyDemandSummaryBatch(type, dealerId, beforeNMonth+1));
            }else {
                System.debug('후속배치');
                // 후속 배치
                if(!Test.isRunningTest()) {

                    switch on type {
                        when DEALER {
                            Set<String> dealerIds = new Set<String>();
                            for(User user : [ SELECT AccountId, Account.CustomerCode__c FROM User WHERE UserType = 'PowerPartner' and Profile.Name ='DNS CS Parts_Partner' AND IsActive = true]) {
                                dealerIds.add(user.AccountId);
                            }
                            Database.executeBatch(new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.DEALER, dealerIds), 200);
                        }
                        when REGION {
                            Set<String> regionIds = new Set<String>();
                            for(AreaByMPPS__c region : [ SELECT Id FROM AreaByMPPS__c ]) {
                                regionIds.add(region.Id);
                            }
                            Database.executeBatch(new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.REGION, regionIds), 200);
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            String log = ''
                       + ' Exception : ' + e.getStackTraceString()
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_MonthlyDemandSummaryBatch', 'finish', 'BatchApex', log);
        } finally {
            logger.insertLog();
        }   
    }

    /*
    * @ Method : setReplacingInfo
    * @ Description : Last Parts 는 대체 이전 품번의 모든 수요를 포함한다. 대체품이 A->B 일 때 A의 Demand를 B의 Demand에 이전한다.
    * @ Description : Summary 한 데이터 대입.
    */
    private void setReplacingInfo(SObject summary) {
        String lastPartId = String.valueOf(summary.get('Part__c'));
        if(replacingInfoMap.containsKey(lastPartId)) {
            Set<String> replacingList = new Set<String>(replacingInfoMap.get(lastPartId).split('_'));
            Decimal quantity = 0;
            Decimal frequency = 0;
            for(String replacingId : replacingList) {
                if('null' == replacingId) continue;

                if(partIdQuantityMap.containsKey(replacingId)) {
                    quantity += partIdQuantityMap.get(replacingId);
                }

                if(partIdFrequencyMap.containsKey(replacingId)) {
                    frequency += partIdFrequencyMap.get(replacingId);
                }
            }

            summary.put('ReplacementQuantitiy__c' , quantity);
            summary.put('ReplacementFrequency__c' , frequency);
            summary.put('Replace__c' , '');
        }
    }

    public class CustomException extends Exception {}
}